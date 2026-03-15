import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/cart_provider.dart';

class ProductCard extends ConsumerWidget {
  final ProductEntity product;
  final bool isGridView;

  const ProductCard({super.key, required this.product, this.isGridView = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}', extra: product),
      child: isGridView ? _buildGridCard(context, ref) : _buildListCard(context, ref),
    );
  }

  Widget _buildGridCard(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5), width: 0.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: CachedNetworkImage(
                    imageUrl: product.mainThumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.dividerBorder.withOpacity(0.3),
                      child: const Center(child: Icon(Icons.image_outlined, color: AppColors.textSecondary)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.dividerBorder.withOpacity(0.3),
                      child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              if (!product.isInStock)
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                    child: const Text('Out of Stock', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ),
              if (product.isSellerVerified)
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, height: 1.2),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                if (product.reviewCount > 0) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    RatingBarIndicator(
                      rating: product.averageRating, itemSize: 12,
                      itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppColors.ratingActive),
                      unratedColor: AppColors.ratingInactive,
                    ),
                    const SizedBox(width: 4),
                    Text('(${product.reviewCount})', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ]),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(AppFormatters.formatCurrency(product.price),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primaryGradientStart, fontWeight: FontWeight.w800)),
                    ),
                    _AddToCartButton(product: product),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5), width: 0.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: product.mainThumbnailUrl, width: 110, height: 110, fit: BoxFit.cover,
              placeholder: (_, __) => Container(width: 110, color: AppColors.dividerBorder.withOpacity(0.3),
                  child: const Icon(Icons.image_outlined, color: AppColors.textSecondary)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(product.sellerName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppFormatters.formatCurrency(product.price),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primaryGradientStart, fontWeight: FontWeight.w800)),
                      _AddToCartButton(product: product, compact: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToCartButton extends ConsumerWidget {
  final ProductEntity product;
  final bool compact;
  const _AddToCartButton({required this.product, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInCart = ref.watch(cartProvider.notifier).isInCart(product.id);
    return GestureDetector(
      onTap: product.isInStock ? () async {
        final cart = ref.read(cartProvider.notifier);
        if (isInCart) {
          cart.removeFromCart(product.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from cart'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating));
        } else {
          await cart.addToCart(CartItemEntity(
            productId: product.id, title: product.title,
            imageUrl: product.mainThumbnailUrl, price: product.price,
            quantity: 1, maxQuantity: product.stockCount,
            sellerId: product.sellerId, sellerName: product.sellerName,
          ));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to cart'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating));
        }
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: compact ? 32 : 36, height: compact ? 32 : 36,
        decoration: BoxDecoration(
          color: isInCart ? AppColors.success : product.isInStock ? AppColors.primaryGradientStart : AppColors.dividerBorder,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(isInCart ? Icons.check_rounded : Icons.add_rounded, color: Colors.white, size: compact ? 16 : 20),
      ),
    );
  }
}
