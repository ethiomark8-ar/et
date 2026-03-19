import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.productId,
    required super.productTitle,
    required super.productImageUrl,
    required super.price,
    required super.quantity,
    required super.sellerId,
    required super.sellerName,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] as String? ?? '',
      productTitle: map['productTitle'] as String? ?? '',
      productImageUrl: map['productImageUrl'] as String? ?? '',
      price: _parseDouble(map['price']),
      quantity: map['quantity'] as int? ?? 1,
      sellerId: map['sellerId'] as String? ?? '',
      sellerName: map['sellerName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productTitle': productTitle,
        'productImageUrl': productImageUrl,
        'price': price,
        'quantity': quantity,
        'sellerId': sellerId,
        'sellerName': sellerName,
      };

  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return 0.0;
  }
}

class ShippingAddressModel extends ShippingAddress {
  const ShippingAddressModel({
    required super.fullName,
    required super.phoneNumber,
    required super.address,
    required super.city,
    super.state,
    super.country,
  });

  factory ShippingAddressModel.fromMap(Map<String, dynamic> map) {
    return ShippingAddressModel(
      fullName: map['fullName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      state: map['state'] as String?,
      country: map['country'] as String? ?? 'Ethiopia',
    );
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
      };
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.buyerId,
    required super.buyerName,
    required super.items,
    required super.shippingAddress,
    required super.subtotal,
    super.shippingFee,
    required super.totalAmount,
    super.status,
    super.paymentStatus,
    super.paymentTransactionId,
    super.chapaReference,
    super.currency,
    required super.createdAt,
    super.updatedAt,
    super.confirmedAt,
    super.shippedAt,
    super.deliveredAt,
    super.cancelledAt,
    super.cancellationReason,
    super.trackingNumber,
    super.notes,
    super.hasBeenReviewed,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromMap(data, doc.id);
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      buyerId: map['buyerId'] as String? ?? '',
      buyerName: map['buyerName'] as String? ?? '',
      items: ((map['items'] as List?) ?? [])
          .map((e) => OrderItemModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      shippingAddress: ShippingAddressModel.fromMap(
        map['shippingAddress'] as Map<String, dynamic>? ?? {},
      ),
      subtotal: _parseDouble(map['subtotal']),
      shippingFee: _parseDouble(map['shippingFee']),
      totalAmount: _parseDouble(map['totalAmount']),
      status: _parseOrderStatus(map['status'] as String?),
      paymentStatus: _parsePaymentStatus(map['paymentStatus'] as String?),
      paymentTransactionId: map['paymentTransactionId'] as String?,
      chapaReference: map['chapaReference'] as String?,
      currency: map['currency'] as String? ?? 'ETB',
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? _parseTimestamp(map['updatedAt']) : null,
      confirmedAt: map['confirmedAt'] != null ? _parseTimestamp(map['confirmedAt']) : null,
      shippedAt: map['shippedAt'] != null ? _parseTimestamp(map['shippedAt']) : null,
      deliveredAt: map['deliveredAt'] != null ? _parseTimestamp(map['deliveredAt']) : null,
      cancelledAt: map['cancelledAt'] != null ? _parseTimestamp(map['cancelledAt']) : null,
      cancellationReason: map['cancellationReason'] as String?,
      trackingNumber: map['trackingNumber'] as String?,
      notes: map['notes'] as String?,
      hasBeenReviewed: map['hasBeenReviewed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'buyerName': buyerName,
      'items': items
          .map((e) => OrderItemModel(
                productId: e.productId,
                productTitle: e.productTitle,
                productImageUrl: e.productImageUrl,
                price: e.price,
                quantity: e.quantity,
                sellerId: e.sellerId,
                sellerName: e.sellerName,
              ).toMap())
          .toList(),
      'shippingAddress': ShippingAddressModel(
        fullName: shippingAddress.fullName,
        phoneNumber: shippingAddress.phoneNumber,
        address: shippingAddress.address,
        city: shippingAddress.city,
        state: shippingAddress.state,
        country: shippingAddress.country,
      ).toMap(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'paymentTransactionId': paymentTransactionId,
      'chapaReference': chapaReference,
      'currency': currency,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'shippedAt': shippedAt != null ? Timestamp.fromDate(shippedAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
      'trackingNumber': trackingNumber,
      'notes': notes,
      'hasBeenReviewed': hasBeenReviewed,
    };
  }

  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return 0.0;
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static OrderStatus _parseOrderStatus(String? status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.pending,
    );
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => PaymentStatus.pending,
    );
  }
}
