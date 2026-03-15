import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  /// Get or create a chat between buyer and seller
  Future<Either<Failure, ChatEntity>> getOrCreateChat({
    required String buyerId,
    required String sellerId,
    String? productId,
    String? productTitle,
    String? productImageUrl,
  });

  /// Get chat by ID
  Future<Either<Failure, ChatEntity>> getChatById(String chatId);

  /// Get all chats for user
  Future<Either<Failure, List<ChatEntity>>> getUserChats(String userId);

  /// Send a text message
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    String? replyToContent,
  });

  /// Send an image message
  Future<Either<Failure, MessageEntity>> sendImageMessage({
    required String chatId,
    required File image,
  });

  /// Mark messages as read
  Future<Either<Failure, void>> markMessagesAsRead(String chatId, String userId);

  /// Stream messages in a chat
  Stream<List<MessageEntity>> watchMessages(String chatId);

  /// Stream all user chats
  Stream<List<ChatEntity>> watchUserChats(String userId);

  /// Queue offline message
  Future<Either<Failure, void>> queueOfflineMessage(MessageEntity message);

  /// Sync offline messages
  Future<Either<Failure, void>> syncOfflineMessages(String chatId);

  /// Get total unread count
  Stream<int> watchTotalUnreadCount(String userId);
}
