import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/loading_overlay.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  final ProductEntity? product;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.product,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _imageIndex = 0;
  bool _showFullDescription = false;

  @override
  void initState() {
    super.initState();
    // Increment view count
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productRepositoryProvider).incrementViewCount(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));
    final product = productAsync.value ?? widget.product;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: productAsync.isLoading
            ? const Center(child: CircularProgressIndicator())
            : const Center(child: Text('Product not found')),
      );
    }

    final isInCart = ref.watch(cartProvider.notifier).isInCart(product.id);
    final currentUser = ref.watch(currentUserProvider);
    final isSeller = currentUser?.id == product.sellerId;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Image Gallery App Bar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: _buildBackButton(context),
            actions: [
              IconButton(
                onPressed: () => Share.share(
                  'Check out ${product.title} on EthioShop! ETB ${product.price}',
                ),
                icon: const Icon(Icons.share_rounded),
              ),
              _buildWishlistButton(product),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(product),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Status
                  Row(
                    children: [
                      _buildChip(product.category),
                      const SizedBox(width: 8),
                      if (!product.isInStock)
                        _buildChip('Out of Stock', color: AppColors.error)
                      else if (product.isLowStock)
                        _buildChip('Only ${product.stockCount} left', color: AppColors.warning),
                      if (product.isSellerVerified) ...[
                        const SizedBox(width: 8),
                        _buildChip('Verified Seller', color: AppColors.success),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Text(
                    AppFormatters.formatCurrency(product.price),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primaryGradientStart,
                          fontWeight: FontWeight.w900,
                        ),
                  ),

                  const SizedBox(height: 12),

                  // Rating
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: product.averageRating,
                        itemSize: 18,
                        itemBuilder: (_, __) =>
                            const Icon(Icons.star_rounded, color: AppColors.ratingActive),
                        unratedColor: AppColors.ratingInactive,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppFormatters.formatRating(product.averageRating),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppFormatters.formatReviewCount(product.reviewCount),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedCrossFade(
                    firstChild: Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    secondChild: Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                    ),
                    crossFadeState: _showFullDescription
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  if (product.description.length > 200)
                    TextButton(
                      onPressed: () =>
                          setState(() => _showFullDescription = !_showFullDescription),
                      child: Text(_showFullDescription ? 'Show less' : 'Read more'),
                    ),

                  const SizedBox(height: 16),
                  const Divider(),

                  // Seller Card
                  _buildSellerCard(context, product, isSeller),

                  const SizedBox(height: 16),

                  // Product specs
                  if (product.brand != null || product.condition != null) ...[
                    _buildSpecsSection(context, product),
                    const SizedBox(height: 16),
                  ],

                  // Quantity selector
                  if (!isSeller && product.isInStock)
                    _buildQuantitySelector(context),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom action bar
      bottomNavigationBar: _buildBottomBar(context, product, isInCart, isSeller),
    );
  }

  Widget _buildImageCarousel(ProductEntity product) {
    if (product.imageUrls.isEmpty) {
      return Container(
        color: AppColors.dividerBorder.withOpacity(0.3),
        child: const Icon(Icons.image_outlined, size: 80, color: AppColors.textSecondary),
      );
    }

    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: product.imageUrls.length,
          itemBuilder: (context, index, _) => GestureDetector(
            onTap: () => _openImageViewer(product.imageUrls, index),
            child: CachedNetworkImage(
              imageUrl: product.imageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          options: CarouselOptions(
            height: 320,
            viewportFraction: 1.0,
            onPageChanged: (index, _) => setState(() => _imageIndex = index),
          ),
        ),
        // Image counter
        if (product.imageUrls.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_imageIndex + 1}/${product.imageUrls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  void _openImageViewer(List<String> images, int initial) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PhotoViewGallery.builder(
            itemCount: images.length,
            builder: (_, index) => PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(images[index]),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
            pageController: PageController(initialPage: initial),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildWishlistButton(ProductEntity product) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          onPressed: () {
            final userId = ref.read(currentUserProvider)?.id;
            if (userId != null) {
              ref.read(toggleWishlistUseCaseProvider).call(product.id, userId);
            }
          },
          icon: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildChip(String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (color ?? AppColors.secondaryAccent).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color ?? AppColors.secondaryAccent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, ProductEntity product, bool isSeller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerBorder, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryGradientStart,
            backgroundImage: product.sellerAvatarUrl != null
                ? CachedNetworkImageProvider(product.sellerAvatarUrl!)
                : null,
            child: product.sellerAvatarUrl == null
                ? Text(product.sellerName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(product.sellerName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    if (product.isSellerVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded,
                          color: AppColors.success, size: 16),
                    ],
                  ],
                ),
                const Text('Seller', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          if (!isSeller)
            TextButton.icon(
              onPressed: () async {
                final currentUser = ref.read(currentUserProvider);
                if (currentUser == null) return;
                final chat = await ref.read(chatNotifierProvider.notifier).getOrCreateChat(
                      sellerId: product.sellerId,
                      productId: product.id,
                      productTitle: product.title,
                      productImageUrl: product.mainThumbnailUrl,
                    );
                if (chat != null && context.mounted) {
                  context.push('/chat/${chat.id}', extra: {
                    'otherUserName': product.sellerName,
                    'otherUserAvatar': product.sellerAvatarUrl,
                  });
                }
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              label: const Text('Chat'),
            ),
        ],
      ),
    );
  }

  Widget _buildSpecsSection(BuildContext context, ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Specifications',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (product.brand != null)
            _buildSpecRow('Brand', product.brand!),
          if (product.condition != null)
            _buildSpecRow('Condition', product.condition!),
          _buildSpecRow('Stock', product.stockCount.toString()),
          _buildSpecRow('Views', product.viewCount.toString()),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    return Row(
      children: [
        Text('Quantity:', style: Theme.of(context).textTheme.titleSmall),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dividerBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                icon: const Icon(Icons.remove_rounded),
                iconSize: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$_quantity',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              IconButton(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(Icons.add_rounded),
                iconSize: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
      BuildContext context, ProductEntity product, bool isInCart, bool isSeller) {
    if (isSeller) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            onPressed: () => context.push('/product/edit/${product.id}', extra: product),
            label: 'Edit Product',
            icon: Icons.edit_rounded,
          ),
        ),
      );
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: AppColors.dividerBorder.withOpacity(0.5))),
        ),
        child: Row(
          children: [
            // Total price
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(
                  AppFormatters.formatCurrency(product.price * _quantity),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.primaryGradientStart,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Add to cart button
            Expanded(
              child: AppButton(
                onPressed: product.isInStock
                    ? () async {
                        final cart = ref.read(cartProvider.notifier);
                        if (isInCart) {
                          await cart.removeFromCart(product.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Removed from cart')),
                          );
                        } else {
                          await cart.addToCart(CartItemEntity(
                            productId: product.id,
                            title: product.title,
                            imageUrl: product.mainThumbnailUrl,
                            price: product.price,
                            quantity: _quantity,
                            maxQuantity: product.stockCount,
                            sellerId: product.sellerId,
                            sellerName: product.sellerName,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart!')),
                          );
                        }
                      }
                    : null,
                label: isInCart ? 'Remove from Cart' : 'Add to Cart',
                icon: isInCart ? Icons.remove_shopping_cart_outlined : Icons.shopping_cart_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
