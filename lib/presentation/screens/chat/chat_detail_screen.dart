import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/message_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String otherUserName;
  final String? otherUserAvatar;
  const ChatDetailScreen({super.key, required this.chatId, required this.otherUserName, this.otherUserAvatar});
  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).markAsRead(widget.chatId);
    });
  }

  @override
  void dispose() { _messageCtrl.dispose(); _scrollController.dispose(); super.dispose(); }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    _messageCtrl.clear();
    await ref.read(chatNotifierProvider.notifier).sendMessage(widget.chatId, text);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _sendImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file == null) return;
    await ref.read(chatNotifierProvider.notifier).sendImageMessage(widget.chatId, File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesStreamProvider(widget.chatId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryGradientStart,
            backgroundImage: widget.otherUserAvatar != null ? CachedNetworkImageProvider(widget.otherUserAvatar!) : null,
            child: widget.otherUserAvatar == null ? Text(widget.otherUserName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)) : null,
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.otherUserName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ]),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: messagesAsync.when(
            data: (messages) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (_, i) => _MessageBubble(
                  message: messages[i],
                  isMe: messages[i].senderId == currentUserId,
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Failed to load messages')),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: AppColors.dividerBorder.withOpacity(0.5))),
          ),
          child: SafeArea(
            child: Row(children: [
              IconButton(onPressed: _sendImage, icon: const Icon(Icons.image_outlined, color: AppColors.textSecondary)),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.dividerBorder),
                  ),
                  child: TextField(
                    controller: _messageCtrl,
                    decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(color: AppColors.primaryGradientStart, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message; final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 8),
        padding: message.type == MessageType.image ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryGradientStart : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: AppColors.dividerBorder.withOpacity(0.5)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
          if (message.type == MessageType.image)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(imageUrl: message.content, width: 200, height: 200, fit: BoxFit.cover),
            )
          else
            Text(message.content, style: TextStyle(color: isMe ? Colors.white : null, fontSize: 14, height: 1.4)),
          const SizedBox(height: 4),
          Text(timeago.format(message.createdAt),
              style: TextStyle(color: isMe ? Colors.white.withOpacity(0.6) : AppColors.textSecondary, fontSize: 10)),
        ]),
      ),
    );
  }
}