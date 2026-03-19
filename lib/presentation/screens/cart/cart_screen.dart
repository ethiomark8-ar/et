import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/loading_overlay.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (${items.length})'),
        backgroundColor: AppColors.primaryDark,
        actions: [
          if (items.isNotEmpty)
            TextButton(onPressed: () => ref.read(cartProvider.notifier).clearCart(),
                child: const Text('Clear', style: TextStyle(color: Colors.white70))),
        ],
      ),
      body: items.isEmpty
          ? const EmptyStateWidget(icon: Icons.shopping_cart_outlined, title: 'Cart is empty', subtitle: 'Add items to get started')
          : Column(children: [
              Expanded(child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _CartItemCard(item: items[i]),
              )),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(top: BorderSide(color: AppColors.dividerBorder.withOpacity(0.5))),
                ),
                child: SafeArea(child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary)),
                    Text(AppFormatters.formatCurrency(total),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.primaryGradientStart)),
                  ]),
                  const SizedBox(height: 12),
                  AppButton(onPressed: () => context.push(RouteConstants.checkout), label: 'Checkout', icon: Icons.arrow_forward_rounded),
                ])),
              ),
            ]),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  final CartItemEntity item;
  const _CartItemCard({required this.item});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5), width: 0.5),
      ),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(imageUrl: item.imageUrl, width: 80, height: 80, fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(width: 80, height: 80, color: AppColors.dividerBorder))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(item.sellerName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(AppFormatters.formatCurrency(item.subtotal),
                style: const TextStyle(color: AppColors.primaryGradientStart, fontWeight: FontWeight.w800)),
            Row(children: [
              _Btn(icon: Icons.remove_rounded, onTap: () => item.quantity > 1 ? cart.updateQuantity(item.productId, item.quantity - 1) : cart.removeFromCart(item.productId)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700))),
              _Btn(icon: Icons.add_rounded, onTap: item.quantity < item.maxQuantity ? () => cart.updateQuantity(item.productId, item.quantity + 1) : null),
            ]),
          ]),
        ])),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon; final VoidCallback? onTap;
  const _Btn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 28, height: 28,
      decoration: BoxDecoration(
        color: onTap != null ? AppColors.primaryGradientStart.withOpacity(0.1) : AppColors.dividerBorder,
        borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.dividerBorder)),
      child: Icon(icon, size: 16, color: onTap != null ? AppColors.primaryGradientStart : AppColors.textSecondary)));
}