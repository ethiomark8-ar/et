import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/user_entity.dart';

class HomeAppBar extends SliverPersistentHeaderDelegate {
  final UserEntity? user;
  final VoidCallback onToggleView;
  final bool isGridView;

  const HomeAppBar({required this.user, required this.onToggleView, required this.isGridView});

  @override
  double get minExtent => 70;
  @override
  double get maxExtent => 130;
  @override
  bool shouldRebuild(covariant HomeAppBar old) => user != old.user || isGridView != old.isGridView;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final collapsed = shrinkOffset / (maxExtent - minExtent) > 0.5;
    return Container(
      color: collapsed ? AppColors.primaryDark : Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Expanded(child: collapsed
                ? const Text('EthioShop', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))
                : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text('Hello, ${user?.fullName.split(' ').first ?? 'Shopper'} 👋',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text('Find what you need today',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  ])),
            IconButton(onPressed: onToggleView,
                icon: Icon(isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                    color: collapsed ? Colors.white : AppColors.textPrimary)),
            IconButton(onPressed: () => context.push(RouteConstants.chatList),
                icon: Icon(Icons.chat_bubble_outline_rounded, color: collapsed ? Colors.white : AppColors.textPrimary)),
            GestureDetector(
              onTap: () => context.go(RouteConstants.profile),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryGradientStart,
                backgroundImage: user?.avatarUrl != null ? CachedNetworkImageProvider(user!.avatarUrl!) : null,
                child: user?.avatarUrl == null
                    ? Text(user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))
                    : null,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}