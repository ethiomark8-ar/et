import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/providers.dart';
import '../../widgets/loading_overlay.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(FutureProvider((r) => r.read(userRepositoryProvider).getAllUsers()));
    return Scaffold(
      appBar: AppBar(title: const Text('All Users'), backgroundColor: AppColors.primaryDark),
      body: usersAsync.when(
        data: (result) => result.fold(
          (f) => ErrorStateWidget(message: f.message),
          (users) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final u = users[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5)),
                ),
                child: Row(children: [
                  CircleAvatar(radius: 20, backgroundColor: AppColors.primaryGradientStart,
                      child: Text(u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(u.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text(u.role.name.toUpperCase(), style: const TextStyle(color: AppColors.secondaryAccent, fontSize: 11, fontWeight: FontWeight.w700)),
                  ])),
                  Switch(
                    value: u.isActive,
                    onChanged: (v) => ref.read(userRepositoryProvider).toggleUserActive(u.id, v),
                    activeColor: AppColors.success,
                  ),
                ]),
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