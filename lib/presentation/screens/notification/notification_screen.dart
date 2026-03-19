import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/loading_overlay.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), backgroundColor: AppColors.primaryDark),
      body: const EmptyStateWidget(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications',
        subtitle: 'You are all caught up! Order updates and messages will appear here.',
      ),
    );
  }
}