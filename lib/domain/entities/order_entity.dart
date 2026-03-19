import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled,
  refunded,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
  inEscrow,
  released,
}

class OrderItem extends Equatable {
  final String productId;
  final String productTitle;
  final String productImageUrl;
  final double price;
  final int quantity;
  final String sellerId;
  final String sellerName;

  const OrderItem({
    required this.productId,
    required this.productTitle,
    required this.productImageUrl,
    required this.price,
    required this.quantity,
    required this.sellerId,
    required this.sellerName,
  });

  double get subtotal => price * quantity;

  @override
  List<Object?> get props => [productId, quantity, price];
}

class ShippingAddress extends Equatable {
  final String fullName;
  final String phoneNumber;
  final String address;
  final String city;
  final String? state;
  final String country;

  const ShippingAddress({
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.city,
    this.state,
    this.country = 'Ethiopia',
  });

  @override
  List<Object?> get props => [fullName, phoneNumber, address, city, country];
}

class OrderEntity extends Equatable {
  final String id;
  final String buyerId;
  final String buyerName;
  final List<OrderItem> items;
  final ShippingAddress shippingAddress;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentTransactionId;
  final String? chapaReference;
  final String currency;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? trackingNumber;
  final String? notes;
  final bool hasBeenReviewed;

  const OrderEntity({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.items,
    required this.shippingAddress,
    required this.subtotal,
    this.shippingFee = 0.0,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentTransactionId,
    this.chapaReference,
    this.currency = 'ETB',
    required this.createdAt,
    this.updatedAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
    this.trackingNumber,
    this.notes,
    this.hasBeenReviewed = false,
  });

  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;
  bool get canReview =>
      status == OrderStatus.delivered && !hasBeenReviewed;
  bool get isPaid => paymentStatus == PaymentStatus.paid ||
      paymentStatus == PaymentStatus.inEscrow ||
      paymentStatus == PaymentStatus.released;

  OrderEntity copyWith({
    String? id,
    String? buyerId,
    String? buyerName,
    List<OrderItem>? items,
    ShippingAddress? shippingAddress,
    double? subtotal,
    double? shippingFee,
    double? totalAmount,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentTransactionId,
    String? chapaReference,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? trackingNumber,
    String? notes,
    bool? hasBeenReviewed,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      chapaReference: chapaReference ?? this.chapaReference,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      hasBeenReviewed: hasBeenReviewed ?? this.hasBeenReviewed,
    );
  }

  @override
  List<Object?> get props => [id, buyerId, status, paymentStatus, totalAmount, createdAt];
}
