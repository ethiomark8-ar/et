import 'package:hive/hive.dart';
import '../../core/constants/hive_constants.dart';
import '../../domain/entities/cart_item_entity.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: HiveConstants.cartItemTypeId)
class CartItemModel extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final double price;

  @HiveField(4)
  int quantity;

  @HiveField(5)
  final int maxQuantity;

  @HiveField(6)
  final String sellerId;

  @HiveField(7)
  final String sellerName;

  @HiveField(8)
  final bool isAvailable;

  CartItemModel({
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

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      productId: entity.productId,
      title: entity.title,
      imageUrl: entity.imageUrl,
      price: entity.price,
      quantity: entity.quantity,
      maxQuantity: entity.maxQuantity,
      sellerId: entity.sellerId,
      sellerName: entity.sellerName,
      isAvailable: entity.isAvailable,
    );
  }

  CartItemEntity toEntity() {
    return CartItemEntity(
      productId: productId,
      title: title,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity,
      maxQuantity: maxQuantity,
      sellerId: sellerId,
      sellerName: sellerName,
      isAvailable: isAvailable,
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'title': title,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
        'maxQuantity': maxQuantity,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'isAvailable': isAvailable,
      };

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'] as String,
      title: map['title'] as String,
      imageUrl: map['imageUrl'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      maxQuantity: map['maxQuantity'] as int? ?? 99,
      sellerId: map['sellerId'] as String,
      sellerName: map['sellerName'] as String,
      isAvailable: map['isAvailable'] as bool? ?? true,
    );
  }
}
