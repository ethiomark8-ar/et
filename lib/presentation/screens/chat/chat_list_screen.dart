import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/message_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/loading_overlay.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(userChatsStreamProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), backgroundColor: AppColors.primaryDark),
      body: chatsAsync.when(
        data: (chats) => chats.isEmpty
            ? const EmptyStateWidget(icon: Icons.chat_bubble_outline_rounded, title: 'No messages yet', subtitle: 'Start a conversation with a seller')
            : ListView.separated(
                itemCount: chats.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                itemBuilder: (_, i) {
                  final chat = chats[i];
                  final isMyMessage = chat.lastMessageSenderId == currentUserId;
                  final otherUserId = chat.participantIds.firstWhere((id) => id != currentUserId, orElse: () => '');
                  final otherName = chat.participantNames[otherUserId] ?? 'User';
                  final otherAvatar = chat.participantAvatars[otherUserId];
                  final unread = chat.unreadCounts[currentUserId] ?? 0;
                  return ListTile(
                    onTap: () => context.push('/chat/${chat.id}', extra: {'otherUserName': otherName, 'otherUserAvatar': otherAvatar}),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primaryGradientStart,
                      backgroundImage: otherAvatar != null ? CachedNetworkImageProvider(otherAvatar) : null,
                      child: otherAvatar == null ? Text(otherName.isNotEmpty ? otherName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)) : null,
                    ),
                    title: Text(otherName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Row(children: [
                      if (isMyMessage) const Icon(Icons.done_all_rounded, size: 14, color: AppColors.textSecondary),
                      Expanded(child: Text(chat.lastMessage ?? '', overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: unread > 0 ? AppColors.primaryGradientStart : AppColors.textSecondary,
                              fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal, fontSize: 13))),
                    ]),
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      if (chat.lastMessageAt != null)
                        Text(timeago.format(chat.lastMessageAt!),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      if (unread > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primaryGradientStart, borderRadius: BorderRadius.circular(10)),
                          child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ]),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
      ),
    );
  }
}