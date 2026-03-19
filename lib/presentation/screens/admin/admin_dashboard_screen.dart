import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_button.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), backgroundColor: AppColors.primaryDark),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _AdminCard(icon: Icons.people_outline_rounded, title: 'Manage Users', subtitle: 'View and manage all users', onTap: () => context.push(RouteConstants.adminUsers)),
          const SizedBox(height: 12),
          _AdminCard(icon: Icons.verified_outlined, title: 'Seller Verifications', subtitle: 'Review pending seller applications', onTap: () => context.push(RouteConstants.adminVerifications)),
          const SizedBox(height: 12),
          _AdminCard(icon: Icons.receipt_long_outlined, title: 'All Orders', subtitle: 'Monitor all platform orders', onTap: () => context.push(RouteConstants.adminOrders)),
        ]),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  const _AdminCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5)),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primaryGradientStart.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primaryGradientStart, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ])),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ]),
    ),
  );
}