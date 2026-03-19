import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/order_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/loading_overlay.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderStreamProvider(orderId));
    final currentUserId = ref.watch(currentUserIdProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details'), backgroundColor: AppColors.primaryDark),
      body: orderAsync.when(
        data: (order) => order == null ? const Center(child: Text('Order not found')) : _buildBody(context, ref, order, currentUserId),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, OrderEntity order, String? currentUserId) {
    final isBuyer = order.buyerId == currentUserId;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Status card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Text('Order #${orderId.substring(0, 8).toUpperCase()}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text(AppFormatters.formatOrderStatus(order.status),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(AppFormatters.formatDateTime(order.createdAt),
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 16),
        // Items
        Text('Items', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...order.items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5)),
          ),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(imageUrl: item.productImageUrl, width: 60, height: 60, fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(width: 60, height: 60, color: AppColors.dividerBorder))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.productTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2),
              const SizedBox(height: 4),
              Text('${item.quantity} x ${AppFormatters.formatCurrency(item.price)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ])),
            Text(AppFormatters.formatCurrency(item.total),
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryGradientStart)),
          ]),
        )),
        const SizedBox(height: 16),
        // Price breakdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5)),
          ),
          child: Column(children: [
            _priceRow('Subtotal', order.totalAmount - order.shippingFee),
            _priceRow('Shipping', order.shippingFee),
            const Divider(),
            _priceRow('Total', order.totalAmount, bold: true),
          ]),
        ),
        const SizedBox(height: 16),
        // Shipping address
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Delivery Address', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(order.shippingAddress.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(order.shippingAddress.phoneNumber, style: const TextStyle(color: AppColors.textSecondary)),
            Text('${order.shippingAddress.addressLine}, ${order.shippingAddress.city}',
                style: const TextStyle(color: AppColors.textSecondary)),
          ]),
        ),
        const SizedBox(height: 24),
        // Actions
        if (isBuyer && order.status == OrderStatus.delivered && !order.hasBeenReviewed)
          AppButton(
            onPressed: () => context.push('/review/write/$orderId', extra: {
              'productId': order.items.first.productId,
              'productTitle': order.items.first.productTitle,
            }),
            label: 'Write a Review',
            icon: Icons.rate_review_outlined,
          ),
        if (isBuyer && order.status == OrderStatus.shipped)
          AppButton(
            onPressed: () async {
              final success = await ref.read(checkoutProvider.notifier).confirmDelivery(orderId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery confirmed!')));
              }
            },
            label: 'Confirm Delivery',
            icon: Icons.check_circle_outlined,
          ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _priceRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
            color: bold ? null : AppColors.textSecondary)),
        Text(AppFormatters.formatCurrency(amount),
            style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: bold ? AppColors.primaryGradientStart : null)),
      ]),
    );
  }
}