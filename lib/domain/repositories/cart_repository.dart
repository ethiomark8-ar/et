import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  /// Get all cart items (offline-first from Hive)
  Future<Either<Failure, List<CartItemEntity>>> getCartItems();

  /// Add item to cart
  Future<Either<Failure, void>> addToCart(CartItemEntity item);

  /// Update item quantity
  Future<Either<Failure, void>> updateQuantity(String productId, int quantity);

  /// Remove item from cart
  Future<Either<Failure, void>> removeFromCart(String productId);

  /// Clear entire cart
  Future<Either<Failure, void>> clearCart();

  /// Check if product is in cart
  Future<Either<Failure, bool>> isInCart(String productId);

  /// Get cart item count
  Future<Either<Failure, int>> getCartCount();

  /// Get cart total
  Future<Either<Failure, double>> getCartTotal();

  /// Sync cart with remote Firestore
  Future<Either<Failure, void>> syncCartToRemote(String userId);

  /// Load cart from remote Firestore
  Future<Either<Failure, List<CartItemEntity>>> loadCartFromRemote(String userId);

  /// Stream cart items (reactive updates)
  Stream<List<CartItemEntity>> watchCartItems();
}
