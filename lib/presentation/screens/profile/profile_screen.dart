import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.primaryDark,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white24,
                  backgroundImage: user.avatarUrl != null ? CachedNetworkImageProvider(user.avatarUrl!) : null,
                  child: user.avatarUrl == null
                      ? Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800))
                      : null,
                ),
                const SizedBox(height: 12),
                Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                const SizedBox(height: 8),
                _RoleBadge(role: user.role),
              ])),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              if (user.role == UserRole.seller) ...[
                _MenuItem(icon: Icons.dashboard_outlined, label: 'Seller Dashboard', onTap: () => context.push(RouteConstants.sellerDashboard)),
                _MenuItem(icon: Icons.inventory_2_outlined, label: 'My Products', onTap: () => context.push(RouteConstants.sellerProducts)),
                _MenuItem(icon: Icons.shopping_bag_outlined, label: 'Seller Orders', onTap: () => context.push(RouteConstants.sellerOrders)),
                if (user.sellerVerificationStatus != VerificationStatus.verified)
                  _MenuItem(icon: Icons.verified_outlined, label: 'Get Verified', onTap: () => context.push(RouteConstants.sellerVerification)),
                const Divider(height: 24),
              ],
              if (user.role == UserRole.admin) ...[
                _MenuItem(icon: Icons.admin_panel_settings_outlined, label: 'Admin Dashboard', onTap: () => context.push(RouteConstants.adminDashboard)),
                const Divider(height: 24),
              ],
              _MenuItem(icon: Icons.receipt_long_outlined, label: 'My Orders', onTap: () => context.push(RouteConstants.orders)),
              _MenuItem(icon: Icons.favorite_border_rounded, label: 'Wishlist', onTap: () {}),
              _MenuItem(icon: Icons.chat_bubble_outline_rounded, label: 'Messages', onTap: () => context.push(RouteConstants.chatList)),
              const Divider(height: 24),
              _MenuItem(icon: Icons.person_outline_rounded, label: 'Edit Profile', onTap: () => context.push(RouteConstants.editProfile)),
              _MenuItem(icon: Icons.settings_outlined, label: 'Settings', onTap: () => context.push(RouteConstants.settings)),
              const Divider(height: 24),
              _MenuItem(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                onTap: () => ref.read(authProvider.notifier).signOut(),
                isDestructive: true,
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});
  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    switch (role) {
      case UserRole.admin: label = 'ADMIN'; color = AppColors.notificationYellow; break;
      case UserRole.seller: label = 'SELLER'; color = AppColors.success; break;
      default: label = 'BUYER'; color = AppColors.secondaryAccent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; final bool isDestructive;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.isDestructive = false});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (isDestructive ? AppColors.error : AppColors.primaryGradientStart).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primaryGradientStart, size: 20),
    ),
    title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: isDestructive ? AppColors.error : null)),
    trailing: isDestructive ? null : const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  );
}