import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../entities/cart_item_entity.dart';

abstract class OrderRepository {
  /// Create a new order
  Future<Either<Failure, OrderEntity>> createOrder({
    required List<CartItemEntity> items,
    required ShippingAddress shippingAddress,
    required double totalAmount,
    required double shippingFee,
    String? notes,
  });

  /// Get order by ID
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);

  /// Get all orders for buyer
  Future<Either<Failure, List<OrderEntity>>> getBuyerOrders(String buyerId);

  /// Get all orders for seller
  Future<Either<Failure, List<OrderEntity>>> getSellerOrders(String sellerId);

  /// Get all orders (admin)
  Future<Either<Failure, List<OrderEntity>>> getAllOrders({
    OrderStatus? status,
    int limit = 50,
    String? lastDocumentId,
  });

  /// Update order status
  Future<Either<Failure, OrderEntity>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? cancellationReason,
    String? trackingNumber,
  });

  /// Update payment status after Chapa webhook
  Future<Either<Failure, OrderEntity>> updatePaymentStatus({
    required String orderId,
    required PaymentStatus paymentStatus,
    required String transactionId,
    String? chapaReference,
  });

  /// Confirm delivery (buyer action - releases escrow)
  Future<Either<Failure, OrderEntity>> confirmDelivery(String orderId);

  /// Stream buyer orders
  Stream<List<OrderEntity>> watchBuyerOrders(String buyerId);

  /// Stream seller orders
  Stream<List<OrderEntity>> watchSellerOrders(String sellerId);

  /// Stream specific order
  Stream<OrderEntity> watchOrder(String orderId);

  /// Initiate Chapa payment
  Future<Either<Failure, Map<String, String>>> initiatePayment({
    required String orderId,
    required double amount,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });

  /// Verify Chapa payment
  Future<Either<Failure, bool>> verifyPayment(String chapaReference);
}
