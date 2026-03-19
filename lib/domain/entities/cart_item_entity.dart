import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String productId;
  final String title;
  final String imageUrl;
  final double price;
  final int quantity;
  final int maxQuantity;
  final String sellerId;
  final String sellerName;
  final bool isAvailable;

  const CartItemEntity({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.maxQuantity = 99,
    required this.sellerId,
    required this.sellerName,
    this.isAvailable = true,
  });

  double get subtotal => price * quantity;

  bool get canIncrement => quantity < maxQuantity;
  bool get canDecrement => quantity > 1;

  CartItemEntity copyWith({
    String? productId,
    String? title,
    String? imageUrl,
    double? price,
    int? quantity,
    int? maxQuantity,
    String? sellerId,
    String? sellerName,
    bool? isAvailable,
  }) {
    return CartItemEntity(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props => [productId, quantity, price];
}
