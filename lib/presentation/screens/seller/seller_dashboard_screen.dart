import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/app_button.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final statsAsync = userId != null
        ? ref.watch(FutureProvider((ref) => ref.read(userRepositoryProvider).getSellerStats(userId)).future)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Seller Dashboard'), backgroundColor: AppColors.primaryDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          FutureBuilder<Map<String, dynamic>>(
            future: statsAsync,
            builder: (context, snapshot) {
              final stats = snapshot.data;
              return GridView.count(
                crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9,
                children: [
                  _StatCard(icon: Icons.inventory_2_outlined, label: 'Products', value: '${stats?['totalProducts'] ?? 0}', color: AppColors.secondaryAccent),
                  _StatCard(icon: Icons.shopping_bag_outlined, label: 'Orders', value: '${stats?['totalOrders'] ?? 0}', color: AppColors.success),
                  _StatCard(icon: Icons.attach_money_rounded, label: 'Revenue', value: AppFormatters.formatCompactCurrency(stats?['totalRevenue']?.toDouble() ?? 0), color: AppColors.notificationYellow),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          AppButton(onPressed: () => context.push(RouteConstants.productCreate), label: 'Add New Product', icon: Icons.add_rounded),
          const SizedBox(height: 12),
          AppButton(onPressed: () => context.push(RouteConstants.sellerProducts), label: 'Manage Products', isOutlined: true, icon: Icons.inventory_2_outlined),
          const SizedBox(height: 12),
          AppButton(onPressed: () => context.push(RouteConstants.sellerOrders), label: 'Manage Orders', isOutlined: true, icon: Icons.receipt_long_outlined),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label; final String value; final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), textAlign: TextAlign.center),
    ]),
  );
}