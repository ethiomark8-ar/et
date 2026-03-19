import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/order_entity.dart';
import '../../providers/order_provider.dart';
import '../../widgets/loading_overlay.dart';

class SellerOrdersScreen extends ConsumerWidget {
  const SellerOrdersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Orders'), backgroundColor: AppColors.primaryDark),
      body: ordersAsync.when(
        data: (orders) => orders.isEmpty
            ? const EmptyStateWidget(icon: Icons.receipt_long_outlined, title: 'No orders yet')
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final order = orders[i];
                  return GestureDetector(
                    onTap: () => context.push('/order/${order.id}'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5), width: 0.5),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('#${order.id.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          _buildStatusDropdown(context, ref, order),
                        ]),
                        const SizedBox(height: 8),
                        Text('Buyer: ${order.buyerName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text('${order.items.length} item(s) · ${AppFormatters.formatDate(order.createdAt)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(AppFormatters.formatCurrency(order.totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryGradientStart)),
                      ]),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, WidgetRef ref, OrderEntity order) {
    return DropdownButton<OrderStatus>(
      value: order.status,
      underline: const SizedBox.shrink(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryGradientStart),
      items: [OrderStatus.confirmed, OrderStatus.processing, OrderStatus.shipped, OrderStatus.delivered]
          .map((s) => DropdownMenuItem(value: s, child: Text(AppFormatters.formatOrderStatus(s)))).toList(),
      onChanged: (s) {
        if (s != null && s != order.status) {
          ref.read(checkoutProvider.notifier).updateOrderStatus(order.id, s);
        }
      },
    );
  }
}