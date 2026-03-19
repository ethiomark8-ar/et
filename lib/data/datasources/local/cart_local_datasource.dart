import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  List<CartItemModel> getCartItems();
  Future<void> addToCart(CartItemModel item);
  Future<void> updateQuantity(String productId, int quantity);
  Future<void> removeFromCart(String productId);
  Future<void> clearCart();
  bool isInCart(String productId);
  int getCartCount();
  double getCartTotal();
  Stream<List<CartItemModel>> watchCartItems();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final Box<CartItemModel> _cartBox;

  CartLocalDataSourceImpl({required Box<CartItemModel> cartBox})
      : _cartBox = cartBox;

  factory CartLocalDataSourceImpl.fromHive() {
    return CartLocalDataSourceImpl(
      cartBox: Hive.box<CartItemModel>(HiveConstants.cartBox),
    );
  }

  @override
  List<CartItemModel> getCartItems() {
    return _cartBox.values.toList();
  }

  @override
  Future<void> addToCart(CartItemModel item) async {
    try {
      final existingItem = _getItemByProductId(item.productId);
      if (existingItem != null) {
        existingItem.quantity += item.quantity;
        await existingItem.save();
      } else {
        await _cartBox.put(item.productId, item);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to add to cart: ${e.toString()}');
    }
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      final item = _getItemByProductId(productId);
      if (item == null) throw CacheException(message: 'Item not found in cart');
      if (quantity <= 0) {
        await removeFromCart(productId);
        return;
      }
      item.quantity = quantity;
      await item.save();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to update quantity: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFromCart(String productId) async {
    try {
      await _cartBox.delete(productId);
    } catch (e) {
      throw CacheException(message: 'Failed to remove from cart: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _cartBox.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cart: ${e.toString()}');
    }
  }

  @override
  bool isInCart(String productId) {
    return _cartBox.containsKey(productId);
  }

  @override
  int getCartCount() {
    return _cartBox.values.fold(0, (sum, item) => sum + item.quantity);
  }

  @override
  double getCartTotal() {
    return _cartBox.values.fold(0.0, (sum, item) => sum + item.price * item.quantity);
  }

  @override
  Stream<List<CartItemModel>> watchCartItems() {
    return _cartBox.watch().map((_) => _cartBox.values.toList());
  }

  CartItemModel? _getItemByProductId(String productId) {
    return _cartBox.get(productId);
  }
}
