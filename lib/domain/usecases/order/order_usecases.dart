import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/order_repository.dart';
import '../../entities/order_entity.dart';
import '../../entities/cart_item_entity.dart';

class CreateOrderUseCase {
  final OrderRepository _repository;
  const CreateOrderUseCase(this._repository);

  Future<Either<Failure, OrderEntity>> call({
    required List<CartItemEntity> items,
    required ShippingAddress shippingAddress,
    required double totalAmount,
    required double shippingFee,
    String? notes,
  }) {
    return _repository.createOrder(
      items: items,
      shippingAddress: shippingAddress,
      totalAmount: totalAmount,
      shippingFee: shippingFee,
      notes: notes,
    );
  }
}

class GetOrderByIdUseCase {
  final OrderRepository _repository;
  const GetOrderByIdUseCase(this._repository);

  Future<Either<Failure, OrderEntity>> call(String orderId) {
    return _repository.getOrderById(orderId);
  }
}

class GetBuyerOrdersUseCase {
  final OrderRepository _repository;
  const GetBuyerOrdersUseCase(this._repository);

  Future<Either<Failure, List<OrderEntity>>> call(String buyerId) {
    return _repository.getBuyerOrders(buyerId);
  }
}

class GetSellerOrdersUseCase {
  final OrderRepository _repository;
  const GetSellerOrdersUseCase(this._repository);

  Future<Either<Failure, List<OrderEntity>>> call(String sellerId) {
    return _repository.getSellerOrders(sellerId);
  }
}

class UpdateOrderStatusUseCase {
  final OrderRepository _repository;
  const UpdateOrderStatusUseCase(this._repository);

  Future<Either<Failure, OrderEntity>> call({
    required String orderId,
    required OrderStatus status,
    String? cancellationReason,
    String? trackingNumber,
  }) {
    return _repository.updateOrderStatus(
      orderId: orderId,
      status: status,
      cancellationReason: cancellationReason,
      trackingNumber: trackingNumber,
    );
  }
}

class ConfirmDeliveryUseCase {
  final OrderRepository _repository;
  const ConfirmDeliveryUseCase(this._repository);

  Future<Either<Failure, OrderEntity>> call(String orderId) {
    return _repository.confirmDelivery(orderId);
  }
}

class InitiatePaymentUseCase {
  final OrderRepository _repository;
  const InitiatePaymentUseCase(this._repository);

  Future<Either<Failure, Map<String, String>>> call({
    required String orderId,
    required double amount,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) {
    return _repository.initiatePayment(
      orderId: orderId,
      amount: amount,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );
  }
}

class VerifyPaymentUseCase {
  final OrderRepository _repository;
  const VerifyPaymentUseCase(this._repository);

  Future<Either<Failure, bool>> call(String chapaReference) {
    return _repository.verifyPayment(chapaReference);
  }
}
