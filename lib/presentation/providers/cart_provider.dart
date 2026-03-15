import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item_entity.dart';
import 'providers.dart';

class CartNotifier extends StateNotifier<List<CartItemEntity>> {
  final Ref _ref;

  CartNotifier(this._ref) : super([]) {
    _loadCart();
    _watchCart();
  }

  void _loadCart() {
    _ref.read(getCartItemsUseCaseProvider).call().then((result) {
      result.fold((_) {}, (items) => state = items);
    });
  }

  void _watchCart() {
    _ref.read(cartRepositoryProvider).watchCartItems().listen((items) {
      state = items;
    });
  }

  Future<bool> addToCart(CartItemEntity item) async {
    final result = await _ref.read(addToCartUseCaseProvider).call(item);
    return result.fold((_) => false, (_) => true);
  }

  Future<bool> removeFromCart(String productId) async {
    final result = await _ref.read(removeFromCartUseCaseProvider).call(productId);
    return result.fold((_) => false, (_) => true);
  }

  Future<bool> updateQuantity(String productId, int quantity) async {
    final result = await _ref.read(updateQuantityUseCaseProvider).call(productId, quantity);
    return result.fold((_) => false, (_) => true);
  }

  Future<bool> clearCart() async {
    final result = await _ref.read(clearCartUseCaseProvider).call();
    return result.fold((_) => false, (_) => true);
  }

  bool isInCart(String productId) {
    return state.any((item) => item.productId == productId);
  }

  CartItemEntity? getItem(String productId) {
    try {
      return state.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  double get total => state.fold(0.0, (sum, item) => sum + item.subtotal);
  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItemCount => state.length;
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemEntity>>((ref) {
  return CartNotifier(ref);
});

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, item) => sum + item.subtotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});

final cartUniqueCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).length;
});
