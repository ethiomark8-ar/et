const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const cors = require("cors")({ origin: true });

admin.initializeApp();
const db = admin.firestore();

const CHAPA_SECRET_KEY = functions.config().chapa?.secret_key || "CHASECK_TEST-Qto69ETjzvgaMcVG9HBabcHCDLSFdmmS";
const CHAPA_BASE_URL = "https://api.chapa.co/v1";

// ── Initiate Chapa Payment ─────────────────────────────────────────────────
exports.initiatePayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Must be logged in");

  const { orderId, amount, email, firstName, lastName, phoneNumber } = data;
  if (!orderId || !amount || !email) {
    throw new functions.https.HttpsError("invalid-argument", "Missing required fields");
  }

  const txRef = `ETHIOSHOP-${orderId}-${Date.now()}`;

  try {
    const response = await axios.post(
      `${CHAPA_BASE_URL}/transaction/initialize`,
      {
        amount: amount.toString(),
        currency: "ETB",
        email,
        first_name: firstName || "Customer",
        last_name: lastName || "EthioShop",
        phone_number: phoneNumber,
        tx_ref: txRef,
        return_url: `https://ethioshop.app/payment/return?tx_ref=${txRef}`,
        callback_url: `https://us-central1-ethioshop-2253.cloudfunctions.net/paymentWebhook`,
        customization: {
          title: "EthioShop Payment",
          description: `Order #${orderId.substring(0, 8).toUpperCase()}`,
          logo: "https://ethioshop.app/logo.png",
        },
      },
      {
        headers: {
          Authorization: `Bearer ${CHAPA_SECRET_KEY}`,
          "Content-Type": "application/json",
        },
      }
    );

    const checkoutUrl = response.data?.data?.checkout_url;
    if (!checkoutUrl) throw new Error("No checkout URL returned");

    // Store txRef on order document
    await db.collection("orders").doc(orderId).update({
      txRef,
      paymentStatus: "pending",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { checkoutUrl, txRef };
  } catch (err) {
    console.error("Chapa initiate error:", err.response?.data || err.message);
    throw new functions.https.HttpsError("internal", "Failed to initiate payment");
  }
});

// ── Verify Chapa Payment ───────────────────────────────────────────────────
exports.verifyPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Must be logged in");

  const { txRef } = data;
  if (!txRef) throw new functions.https.HttpsError("invalid-argument", "txRef is required");

  try {
    const response = await axios.get(`${CHAPA_BASE_URL}/transaction/verify/${txRef}`, {
      headers: { Authorization: `Bearer ${CHAPA_SECRET_KEY}` },
    });

    const status = response.data?.data?.status;
    const verified = status === "success";

    if (verified) {
      // Find order by txRef and update
      const ordersSnap = await db.collection("orders").where("txRef", "==", txRef).limit(1).get();
      if (!ordersSnap.empty) {
        const orderDoc = ordersSnap.docs[0];
        await orderDoc.ref.update({
          paymentStatus: "paid",
          status: "confirmed",
          transactionId: response.data.data.reference,
          paidAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Update product stock
        const orderData = orderDoc.data();
        const batch = db.batch();
        for (const item of orderData.items || []) {
          const productRef = db.collection("products").doc(item.productId);
          batch.update(productRef, {
            stockCount: admin.firestore.FieldValue.increment(-item.quantity),
          });
        }
        await batch.commit();
      }
    }

    return { verified, status };
  } catch (err) {
    console.error("Chapa verify error:", err.response?.data || err.message);
    return { verified: false, status: "failed" };
  }
});

// ── Chapa Webhook ──────────────────────────────────────────────────────────
exports.paymentWebhook = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") return res.status(405).send("Method Not Allowed");

    const { tx_ref, status } = req.body;
    if (!tx_ref) return res.status(400).send("Missing tx_ref");

    try {
      if (status === "success") {
        const ordersSnap = await db.collection("orders").where("txRef", "==", tx_ref).limit(1).get();
        if (!ordersSnap.empty) {
          await ordersSnap.docs[0].ref.update({
            paymentStatus: "paid",
            status: "confirmed",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }
      res.status(200).json({ received: true });
    } catch (err) {
      console.error("Webhook error:", err);
      res.status(500).send("Internal Error");
    }
  });
});

// ── Release Escrow (when buyer confirms delivery) ──────────────────────────
exports.releaseEscrow = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status) return null;
    if (after.status !== "delivered") return null;

    await change.after.ref.update({
      paymentStatus: "released",
      releasedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Notify seller
    const sellerIds = after.sellerIds || [];
    const batch = db.batch();
    for (const sellerId of sellerIds) {
      const notifRef = db.collection("notifications").doc(sellerId).collection("items").doc();
      batch.set(notifRef, {
        type: "payment_released",
        title: "Payment Released",
        body: `Payment for order #${context.params.orderId.substring(0, 8)} has been released.`,
        orderId: context.params.orderId,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return null;
  });

// ── Send FCM notification on new order ────────────────────────────────────
exports.onNewOrder = functions.firestore
  .document("orders/{orderId}")
  .onCreate(async (snap, context) => {
    const order = snap.data();
    const sellerIds = order.sellerIds || [];

    for (const sellerId of sellerIds) {
      const userSnap = await db.collection("users").doc(sellerId).get();
      const fcmToken = userSnap.data()?.fcmToken;
      if (!fcmToken) continue;

      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: "New Order Received!",
          body: `You have a new order #${context.params.orderId.substring(0, 8).toUpperCase()}`,
        },
        data: { orderId: context.params.orderId, type: "new_order" },
        android: { priority: "high" },
      });
    }
    return null;
  });

// ── Auto-cancel unpaid orders after 30 minutes ────────────────────────────
exports.autoCancelUnpaidOrders = functions.pubsub
  .schedule("every 30 minutes")
  .onRun(async () => {
    const cutoff = new Date(Date.now() - 30 * 60 * 1000);
    const snap = await db.collection("orders")
      .where("status", "==", "pending")
      .where("paymentStatus", "==", "pending")
      .where("createdAt", "<", cutoff)
      .get();

    const batch = db.batch();
    snap.docs.forEach((doc) => {
      batch.update(doc.ref, {
        status: "cancelled",
        cancellationReason: "Payment timeout",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
    await batch.commit();
    console.log(`Auto-cancelled ${snap.docs.length} unpaid orders`);
    return null;
  });