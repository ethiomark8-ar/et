import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message_entity.dart';
import 'auth_provider.dart';
import 'providers.dart';

// All user chats stream
final userChatsStreamProvider = StreamProvider<List<ChatEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(chatRepositoryProvider).watchUserChats(userId);
});

// Messages in a specific chat
final chatMessagesStreamProvider =
    StreamProvider.family<List<MessageEntity>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).watchMessages(chatId);
});

// Total unread count
final totalUnreadCountProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(0);
  return ref.watch(chatRepositoryProvider).watchTotalUnreadCount(userId);
});

class ChatNotifier extends StateNotifier<AsyncValue<ChatEntity?>> {
  final Ref _ref;

  ChatNotifier(this._ref) : super(const AsyncValue.loading());

  Future<ChatEntity?> getOrCreateChat({
    required String sellerId,
    String? productId,
    String? productTitle,
    String? productImageUrl,
  }) async {
    state = const AsyncValue.loading();
    final buyerId = _ref.read(currentUserIdProvider);
    if (buyerId == null) {
      state = const AsyncValue.data(null);
      return null;
    }

    final result = await _ref.read(getOrCreateChatUseCaseProvider).call(
          buyerId: buyerId,
          sellerId: sellerId,
          productId: productId,
          productTitle: productTitle,
          productImageUrl: productImageUrl,
        );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (chat) {
        state = AsyncValue.data(chat);
        return chat;
      },
    );
  }

  Future<bool> sendMessage(String chatId, String content) async {
    final result = await _ref.read(sendMessageUseCaseProvider).call(
          chatId: chatId,
          content: content,
        );
    return result.fold((_) => false, (_) => true);
  }

  Future<bool> sendImageMessage(String chatId, File image) async {
    final result = await _ref.read(sendImageMessageUseCaseProvider).call(
          chatId: chatId,
          image: image,
        );
    return result.fold((_) => false, (_) => true);
  }

  Future<void> markAsRead(String chatId) async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return;
    await _ref.read(markMessagesReadUseCaseProvider).call(chatId, userId);
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<ChatEntity?>>((ref) {
  return ChatNotifier(ref);
});
