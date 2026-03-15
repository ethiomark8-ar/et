import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/cart_repository.dart';
import '../../entities/cart_item_entity.dart';

class AddToCartUseCase {
  final CartRepository _repository;
  const AddToCartUseCase(this._repository);

  Future<Either<Failure, void>> call(CartItemEntity item) {
    return _repository.addToCart(item);
  }
}

class RemoveFromCartUseCase {
  final CartRepository _repository;
  const RemoveFromCartUseCase(this._repository);

  Future<Either<Failure, void>> call(String productId) {
    return _repository.removeFromCart(productId);
  }
}

class UpdateQuantityUseCase {
  final CartRepository _repository;
  const UpdateQuantityUseCase(this._repository);

  Future<Either<Failure, void>> call(String productId, int quantity) {
    return _repository.updateQuantity(productId, quantity);
  }
}

class GetCartItemsUseCase {
  final CartRepository _repository;
  const GetCartItemsUseCase(this._repository);

  Future<Either<Failure, List<CartItemEntity>>> call() {
    return _repository.getCartItems();
  }
}

class ClearCartUseCase {
  final CartRepository _repository;
  const ClearCartUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.clearCart();
  }
}

class GetCartTotalUseCase {
  final CartRepository _repository;
  const GetCartTotalUseCase(this._repository);

  Future<Either<Failure, double>> call() {
    return _repository.getCartTotal();
  }
}

class SyncCartUseCase {
  final CartRepository _repository;
  const SyncCartUseCase(this._repository);

  Future<Either<Failure, void>> call(String userId) {
    return _repository.syncCartToRemote(userId);
  }
}
