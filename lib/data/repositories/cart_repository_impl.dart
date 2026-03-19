import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/local/cart_local_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _localDataSource;
  final FirebaseFirestore _firestore;

  const CartRepositoryImpl({
    required CartLocalDataSource localDataSource,
    required FirebaseFirestore firestore,
  })  : _localDataSource = localDataSource,
        _firestore = firestore;

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCartItems() async {
    try {
      final items = _localDataSource.getCartItems();
      return Right(items.map((e) => e.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(CartItemEntity item) async {
    try {
      final model = CartItemModel.fromEntity(item);
      await _localDataSource.addToCart(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuantity(String productId, int quantity) async {
    try {
      await _localDataSource.updateQuantity(productId, quantity);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String productId) async {
    try {
      await _localDataSource.removeFromCart(productId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await _localDataSource.clearCart();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isInCart(String productId) async {
    try {
      return Right(_localDataSource.isInCart(productId));
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, int>> getCartCount() async {
    try {
      return Right(_localDataSource.getCartCount());
    } catch (e) {
      return const Right(0);
    }
  }

  @override
  Future<Either<Failure, double>> getCartTotal() async {
    try {
      return Right(_localDataSource.getCartTotal());
    } catch (e) {
      return const Right(0.0);
    }
  }

  @override
  Future<Either<Failure, void>> syncCartToRemote(String userId) async {
    try {
      final items = _localDataSource.getCartItems();
      final cartData = items.map((e) => e.toMap()).toList();
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('cart')
          .doc('items')
          .set({'items': cartData, 'updatedAt': FieldValue.serverTimestamp()});
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to sync cart'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> loadCartFromRemote(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('cart')
          .doc('items')
          .get();

      if (!doc.exists) return const Right([]);

      final data = doc.data() as Map<String, dynamic>?;
      final items = (data?['items'] as List?)
          ?.map((e) => CartItemModel.fromMap(e as Map<String, dynamic>).toEntity())
          .toList() ?? [];

      // Load into local cache
      await _localDataSource.clearCart();
      for (final item in items) {
        await _localDataSource.addToCart(CartItemModel.fromEntity(item));
      }

      return Right(items);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load cart'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<List<CartItemEntity>> watchCartItems() {
    return _localDataSource
        .watchCartItems()
        .map((items) => items.map((e) => e.toEntity()).toList());
  }
}
