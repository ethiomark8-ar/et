import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/loading_overlay.dart';

class SellerProductsScreen extends ConsumerWidget {
  const SellerProductsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final productsAsync = userId != null ? ref.watch(sellerProductsProvider(userId)) : const AsyncValue.data([]);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(onPressed: () => context.push(RouteConstants.productCreate), icon: const Icon(Icons.add_rounded)),
        ],
      ),
      body: productsAsync.when(
        data: (products) => products.isEmpty
            ? EmptyStateWidget(icon: Icons.inventory_2_outlined, title: 'No products yet', subtitle: 'Add your first product',
                actionLabel: 'Add Product', onAction: () => context.push(RouteConstants.productCreate))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final p = products[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5), width: 0.5),
                    ),
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(imageUrl: p.mainThumbnailUrl, width: 70, height: 70, fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(width: 70, height: 70, color: AppColors.dividerBorder))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(AppFormatters.formatCurrency(p.price), style: const TextStyle(color: AppColors.primaryGradientStart, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: p.isInStock ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(p.isInStock ? 'In Stock (${p.stockCount})' : 'Out of Stock',
                                style: TextStyle(color: p.isInStock ? AppColors.success : AppColors.error, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ])),
                      IconButton(
                        onPressed: () => context.push('/product/edit/${p.id}', extra: p),
                        icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                      ),
                    ]),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
      ),
    );
  }
}