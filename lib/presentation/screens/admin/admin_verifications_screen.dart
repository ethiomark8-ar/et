import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/providers.dart';
import '../../widgets/loading_overlay.dart';

class AdminVerificationsScreen extends ConsumerWidget {
  const AdminVerificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(FutureProvider((r) => r.read(userRepositoryProvider).getPendingVerifications()));
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Verifications'), backgroundColor: AppColors.primaryDark),
      body: usersAsync.when(
        data: (result) => result.fold(
          (f) => ErrorStateWidget(message: f.message),
          (users) => users.isEmpty
              ? const EmptyStateWidget(icon: Icons.verified_outlined, title: 'No pending verifications')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final u = users[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.dividerBorder.withOpacity(0.5)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(u.businessName ?? 'No business name', style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: ElevatedButton.icon(
                            onPressed: () => ref.read(userRepositoryProvider).updateVerificationStatus(userId: u.id, status: VerificationStatus.verified),
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: ElevatedButton.icon(
                            onPressed: () => ref.read(userRepositoryProvider).updateVerificationStatus(userId: u.id, status: VerificationStatus.rejected, reason: 'Not approved'),
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          )),
                        ]),
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