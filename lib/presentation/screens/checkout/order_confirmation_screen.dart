import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/order_provider.dart';
import '../../widgets/app_button.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  final String orderId;
  const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderStreamProvider(orderId));
    return Scaffold(
      body: SafeArea(
        child: orderAsync.when(
          data: (order) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: const BoxDecoration(color: Color(0xFF1A2A1A), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 72),
                ),
                const SizedBox(height: 32),
                Text('Order Confirmed!', textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Text('Your order #${orderId.substring(0, 8).toUpperCase()} has been placed successfully.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.6)),
                if (order != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5)),
                    ),
                    child: Column(children: [
                      _row(context, 'Total Paid', AppFormatters.formatCurrency(order.totalAmount)),
                      _row(context, 'Items', '${order.items.length} item(s)'),
                      _row(context, 'Deliver to', order.shippingAddress.city),
                    ]),
                  ),
                ],
                const SizedBox(height: 32),
                AppButton(onPressed: () => context.go('/order/$orderId'), label: 'Track My Order', icon: Icons.local_shipping_outlined),
                const SizedBox(height: 12),
                AppButton(onPressed: () => context.go(RouteConstants.home), label: 'Continue Shopping', isOutlined: true),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Order details unavailable')),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    );
  }
}