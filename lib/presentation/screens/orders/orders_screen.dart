import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/order_entity.dart';
import '../../providers/order_provider.dart';
import '../../widgets/loading_overlay.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(buyerOrdersStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders'), backgroundColor: AppColors.primaryDark),
      body: ordersAsync.when(
        data: (orders) => orders.isEmpty
            ? const EmptyStateWidget(icon: Icons.receipt_long_outlined, title: 'No orders yet', subtitle: 'Your orders will appear here')
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _OrderCard(order: orders[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  const _OrderCard({required this.order});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/order/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5), width: 0.5),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('#${order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            _StatusBadge(status: order.status),
          ]),
          const SizedBox(height: 8),
          Text('${order.items.length} item(s)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(AppFormatters.formatDate(order.createdAt), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Text(AppFormatters.formatCurrency(order.totalAmount),
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryGradientStart)),
          ]),
        ]),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case OrderStatus.delivered: color = AppColors.success; break;
      case OrderStatus.cancelled: color = AppColors.error; break;
      case OrderStatus.shipped: color = AppColors.secondaryAccent; break;
      case OrderStatus.confirmed: color = AppColors.primaryGradientStart; break;
      default: color = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(AppFormatters.formatOrderStatus(status), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}