import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import 'auth_provider.dart';
import 'providers.dart';

// Orders state
class OrdersState {
  final List<OrderEntity> orders;
  final bool isLoading;
  final String? error;

  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrdersState copyWith({
    List<OrderEntity>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Buyer orders stream
final buyerOrdersStreamProvider = StreamProvider<List<OrderEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(orderRepositoryProvider).watchBuyerOrders(userId);
});

// Seller orders stream
final sellerOrdersStreamProvider = StreamProvider<List<OrderEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(orderRepositoryProvider).watchSellerOrders(userId);
});

// Single order stream
final orderStreamProvider = StreamProvider.family<OrderEntity?, String>((ref, orderId) {
  return ref.watch(orderRepositoryProvider).watchOrder(orderId).handleError((_) => null);
});

// Checkout state
class CheckoutState {
  final bool isLoading;
  final OrderEntity? order;
  final String? checkoutUrl;
  final String? txRef;
  final String? error;
  final bool paymentSuccess;

  const CheckoutState({
    this.isLoading = false,
    this.order,
    this.checkoutUrl,
    this.txRef,
    this.error,
    this.paymentSuccess = false,
  });

  CheckoutState copyWith({
    bool? isLoading,
    OrderEntity? order,
    String? checkoutUrl,
    String? txRef,
    String? error,
    bool? paymentSuccess,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      order: order ?? this.order,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      txRef: txRef ?? this.txRef,
      error: error,
      paymentSuccess: paymentSuccess ?? this.paymentSuccess,
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref _ref;

  CheckoutNotifier(this._ref) : super(const CheckoutState());

  Future<bool> createOrder({
    required List<CartItemEntity> items,
    required ShippingAddress shippingAddress,
    required double totalAmount,
    required double shippingFee,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _ref.read(createOrderUseCaseProvider).call(
          items: items,
          shippingAddress: shippingAddress,
          totalAmount: totalAmount,
          shippingFee: shippingFee,
          notes: notes,
        );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (order) {
        state = state.copyWith(isLoading: false, order: order);
        return true;
      },
    );
  }

  Future<bool> initiatePayment({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    if (state.order == null) return false;
    state = state.copyWith(isLoading: true, error: null);

    final result = await _ref.read(initiatePaymentUseCaseProvider).call(
          orderId: state.order!.id,
          amount: state.order!.totalAmount,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
        );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (paymentData) {
        state = state.copyWith(
          isLoading: false,
          checkoutUrl: paymentData['checkoutUrl'],
          txRef: paymentData['txRef'],
        );
        return true;
      },
    );
  }

  Future<bool> handlePaymentCallback(String txRef) async {
    state = state.copyWith(isLoading: true);
    final result = await _ref.read(verifyPaymentUseCaseProvider).call(txRef);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message, paymentSuccess: false);
        return false;
      },
      (verified) {
        state = state.copyWith(isLoading: false, paymentSuccess: verified);
        if (verified && state.order != null) {
          _ref.read(updateOrderStatusUseCaseProvider).call(
                orderId: state.order!.id,
                status: OrderStatus.confirmed,
              );
        }
        return verified;
      },
    );
  }

  Future<bool> confirmDelivery(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _ref.read(confirmDeliveryUseCaseProvider).call(orderId);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (order) {
        state = state.copyWith(isLoading: false, order: order);
        return true;
      },
    );
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _ref.read(updateOrderStatusUseCaseProvider).call(
          orderId: orderId,
          status: status,
        );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  void reset() {
    state = const CheckoutState();
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});
