import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/remote/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  const OrderRepositoryImpl({required OrderRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required List<CartItemEntity> items,
    required ShippingAddress shippingAddress,
    required double totalAmount,
    required double shippingFee,
    String? notes,
  }) async {
    try {
      final order = await _remoteDataSource.createOrder(
        items: items,
        shippingAddress: shippingAddress,
        totalAmount: totalAmount,
        shippingFee: shippingFee,
        notes: notes,
      );
      return Right(order);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    try {
      final order = await _remoteDataSource.getOrderById(orderId);
      return Right(order);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getBuyerOrders(String buyerId) async {
    try {
      final orders = await _remoteDataSource.getBuyerOrders(buyerId);
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getSellerOrders(String sellerId) async {
    try {
      final orders = await _remoteDataSource.getSellerOrders(sellerId);
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getAllOrders({
    OrderStatus? status,
    int limit = 50,
    String? lastDocumentId,
  }) async {
    try {
      final orders = await _remoteDataSource.getAllOrders(
        status: status,
        limit: limit,
        lastDocumentId: lastDocumentId,
      );
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? cancellationReason,
    String? trackingNumber,
  }) async {
    try {
      final order = await _remoteDataSource.updateOrderStatus(
        orderId: orderId,
        status: status,
        cancellationReason: cancellationReason,
        trackingNumber: trackingNumber,
      );
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updatePaymentStatus({
    required String orderId,
    required PaymentStatus paymentStatus,
    required String transactionId,
    String? chapaReference,
  }) async {
    try {
      final order = await _remoteDataSource.updatePaymentStatus(
        orderId: orderId,
        paymentStatus: paymentStatus,
        transactionId: transactionId,
        chapaReference: chapaReference,
      );
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> confirmDelivery(String orderId) async {
    try {
      final order = await _remoteDataSource.confirmDelivery(orderId);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<List<OrderEntity>> watchBuyerOrders(String buyerId) {
    return _remoteDataSource.watchBuyerOrders(buyerId);
  }

  @override
  Stream<List<OrderEntity>> watchSellerOrders(String sellerId) {
    return _remoteDataSource.watchSellerOrders(sellerId);
  }

  @override
  Stream<OrderEntity> watchOrder(String orderId) {
    return _remoteDataSource.watchOrder(orderId);
  }

  @override
  Future<Either<Failure, Map<String, String>>> initiatePayment({
    required String orderId,
    required double amount,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final result = await _remoteDataSource.initiatePayment(
        orderId: orderId,
        amount: amount,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      return Right(result);
    } on PaymentException catch (e) {
      return Left(PaymentFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPayment(String chapaReference) async {
    try {
      final verified = await _remoteDataSource.verifyPayment(chapaReference);
      return Right(verified);
    } on PaymentException catch (e) {
      return Left(PaymentFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
