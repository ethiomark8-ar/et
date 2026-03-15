import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/order_model.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/cart_item_entity.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required List<CartItemEntity> items,
    required ShippingAddress shippingAddress,
    required double totalAmount,
    required double shippingFee,
    String? notes,
  });
  Future<OrderModel> getOrderById(String orderId);
  Future<List<OrderModel>> getBuyerOrders(String buyerId);
  Future<List<OrderModel>> getSellerOrders(String sellerId);
  Future<List<OrderModel>> getAllOrders({OrderStatus? status, int limit, String? lastDocumentId});
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? cancellationReason,
    String? trackingNumber,
  });
  Future<OrderModel> updatePaymentStatus({
    required String orderId,
    required PaymentStatus paymentStatus,
    required String transactionId,
    String? chapaReference,
  });
  Future<OrderModel> confirmDelivery(String orderId);
  Stream<List<OrderModel>> watchBuyerOrders(String buyerId);
  Stream<List<OrderModel>> watchSellerOrders(String sellerId);
  Stream<OrderModel> watchOrder(String orderId);
  Future<Map<String, String>> initiatePayment({
    required String orderId,
    required double amount,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });
  Future<bool> verifyPayment(String chapaReference);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Uuid _uuid;

  OrderRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    Uuid? uuid,
  })  : _firestore = firestore,
        _auth = auth,
        _uuid = uuid ?? const Uuid();

  CollectionReference get _ordersRef =>
      _firestore.collection(AppConstants.ordersCollection);

  @override
  Future<OrderModel> createOrder({
    required List<CartItemEntity> items,
    required ShippingAddress shippingAddress,
    required double totalAmount,
    required double shippingFee,
    String? notes,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw const AuthException(message: 'Not authenticated');

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      final buyerName = (userDoc.data() as Map<String, dynamic>?)?['fullName'] as String? ?? '';

      final subtotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
      final docRef = _ordersRef.doc();
      final now = DateTime.now();

      final orderModel = OrderModel(
        id: docRef.id,
        buyerId: userId,
        buyerName: buyerName,
        items: items
            .map((item) => OrderItemModel(
                  productId: item.productId,
                  productTitle: item.title,
                  productImageUrl: item.imageUrl,
                  price: item.price,
                  quantity: item.quantity,
                  sellerId: item.sellerId,
                  sellerName: item.sellerName,
                ))
            .toList(),
        shippingAddress: ShippingAddressModel(
          fullName: shippingAddress.fullName,
          phoneNumber: shippingAddress.phoneNumber,
          address: shippingAddress.address,
          city: shippingAddress.city,
          state: shippingAddress.state,
          country: shippingAddress.country,
        ),
        subtotal: subtotal,
        shippingFee: shippingFee,
        totalAmount: totalAmount,
        createdAt: now,
      );

      await docRef.set(orderModel.toMap());

      // Update product stock counts
      final batch = _firestore.batch();
      for (final item in items) {
        final productRef = _firestore
            .collection(AppConstants.productsCollection)
            .doc(item.productId);
        batch.update(productRef, {
          'stockCount': FieldValue.increment(-item.quantity),
        });
      }
      await batch.commit();

      return orderModel;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to create order', code: e.code);
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final doc = await _ordersRef.doc(orderId).get();
      if (!doc.exists) throw const NotFoundException(message: 'Order not found');
      return OrderModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    } on NotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get order', code: e.code);
    }
  }

  @override
  Future<List<OrderModel>> getBuyerOrders(String buyerId) async {
    try {
      final snapshot = await _ordersRef
          .where('buyerId', isEqualTo: buyerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get orders', code: e.code);
    }
  }

  @override
  Future<List<OrderModel>> getSellerOrders(String sellerId) async {
    try {
      // Get orders where seller has items
      final snapshot = await _ordersRef
          .where('items', arrayContains: {'sellerId': sellerId})
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } on FirebaseException catch (e) {
      // Fallback: get all orders and filter client-side
      try {
        final allSnapshot = await _ordersRef
            .orderBy('createdAt', descending: true)
            .limit(200)
            .get();
        return allSnapshot.docs
            .map((doc) =>
                OrderModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
            .where((order) =>
                order.items.any((item) => item.sellerId == sellerId))
            .toList();
      } catch (_) {
        throw ServerException(message: e.message ?? 'Failed to get seller orders', code: e.code);
      }
    }
  }

  @override
  Future<List<OrderModel>> getAllOrders({
    OrderStatus? status,
    int limit = 50,
    String? lastDocumentId,
  }) async {
    try {
      Query query = _ordersRef.orderBy('createdAt', descending: true);
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      if (lastDocumentId != null) {
        final lastDoc = await _ordersRef.doc(lastDocumentId).get();
        query = query.startAfterDocument(lastDoc);
      }
      query = query.limit(limit);
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get all orders', code: e.code);
    }
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? cancellationReason,
    String? trackingNumber,
  }) async {
    try {
      final now = DateTime.now();
      final updates = <String, dynamic>{
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      switch (status) {
        case OrderStatus.confirmed:
          updates['confirmedAt'] = Timestamp.fromDate(now);
          break;
        case OrderStatus.shipped:
          updates['shippedAt'] = Timestamp.fromDate(now);
          if (trackingNumber != null) updates['trackingNumber'] = trackingNumber;
          break;
        case OrderStatus.delivered:
          updates['deliveredAt'] = Timestamp.fromDate(now);
          break;
        case OrderStatus.cancelled:
          updates['cancelledAt'] = Timestamp.fromDate(now);
          if (cancellationReason != null) updates['cancellationReason'] = cancellationReason;
          break;
        default:
          break;
      }

      await _ordersRef.doc(orderId).update(updates);
      return getOrderById(orderId);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update order status', code: e.code);
    }
  }

  @override
  Future<OrderModel> updatePaymentStatus({
    required String orderId,
    required PaymentStatus paymentStatus,
    required String transactionId,
    String? chapaReference,
  }) async {
    try {
      await _ordersRef.doc(orderId).update({
        'paymentStatus': paymentStatus.name,
        'paymentTransactionId': transactionId,
        if (chapaReference != null) 'chapaReference': chapaReference,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return getOrderById(orderId);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update payment status', code: e.code);
    }
  }

  @override
  Future<OrderModel> confirmDelivery(String orderId) async {
    try {
      await _ordersRef.doc(orderId).update({
        'status': OrderStatus.delivered.name,
        'paymentStatus': PaymentStatus.released.name,
        'deliveredAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return getOrderById(orderId);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to confirm delivery', code: e.code);
    }
  }

  @override
  Stream<List<OrderModel>> watchBuyerOrders(String buyerId) {
    return _ordersRef
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                OrderModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  @override
  Stream<List<OrderModel>> watchSellerOrders(String sellerId) {
    return _ordersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                OrderModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
            .where((order) => order.items.any((item) => item.sellerId == sellerId))
            .toList());
  }

  @override
  Stream<OrderModel> watchOrder(String orderId) {
    return _ordersRef.doc(orderId).snapshots().where((doc) => doc.exists).map(
          (doc) => OrderModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>),
        );
  }

  @override
  Future<Map<String, String>> initiatePayment({
    required String orderId,
    required double amount,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      // In production, this calls a Firebase Cloud Function to securely initiate payment
      // The Cloud Function holds the secret key and calls Chapa API
      final txRef = 'ethioshop-$orderId-${_uuid.v4().substring(0, 8)}';
      
      // Call Firebase Cloud Function (production)
      // final result = await FirebaseFunctions.instance.httpsCallable('initiatePayment').call({...});
      
      // For now, construct the Chapa checkout URL directly with the public key
      final chapaUrl = '${AppConstants.chapaCheckoutBase}${AppConstants.chapaPublicKey}';
      
      return {
        'checkoutUrl': chapaUrl,
        'txRef': txRef,
        'orderId': orderId,
      };
    } catch (e) {
      throw PaymentException(message: 'Failed to initiate payment: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyPayment(String chapaReference) async {
    try {
      // In production, this calls a Firebase Cloud Function for server-side verification
      // The Cloud Function uses the secret key for Chapa verification
      final response = await http.get(
        Uri.parse('${AppConstants.chapaBaseUrl}/transaction/verify/$chapaReference'),
        headers: {
          'Authorization': 'Bearer ${AppConstants.chapaPublicKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      throw PaymentException(message: 'Payment verification failed: ${e.toString()}');
    }
  }
}
