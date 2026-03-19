import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/order_entity.dart';
import '../../providers/providers.dart';
import '../../widgets/loading_overlay.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(FutureProvider((r) => r.read(orderRepositoryProvider).getAllOrders(limit: 100)));
    return Scaffold(
      appBar: AppBar(title: const Text('All Orders'), backgroundColor: AppColors.primaryDark),
      body: ordersAsync.when(
        data: (result) => result.fold(
          (f) => ErrorStateWidget(message: f.message),
          (orders) => orders.isEmpty
              ? const EmptyStateWidget(icon: Icons.receipt_long_outlined, title: 'No orders yet')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final o = orders[i];
                    return GestureDetector(
                      onTap: () => context.push('/order/${o.id}'),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5)),
                        ),
                        child: Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('#${o.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            Text('${o.buyerName} · ${AppFormatters.formatDate(o.createdAt)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text(AppFormatters.formatCurrency(o.totalAmount), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryGradientStart)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.primaryGradientStart.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(AppFormatters.formatOrderStatus(o.status), style: const TextStyle(color: AppColors.primaryGradientStart, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        ]),
                      ),
                    );
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
      ),
    );
  }
}