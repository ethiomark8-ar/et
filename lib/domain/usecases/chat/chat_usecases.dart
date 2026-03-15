import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/chat_repository.dart';
import '../../entities/message_entity.dart';

class GetOrCreateChatUseCase {
  final ChatRepository _repository;
  const GetOrCreateChatUseCase(this._repository);

  Future<Either<Failure, ChatEntity>> call({
    required String buyerId,
    required String sellerId,
    String? productId,
    String? productTitle,
    String? productImageUrl,
  }) {
    return _repository.getOrCreateChat(
      buyerId: buyerId,
      sellerId: sellerId,
      productId: productId,
      productTitle: productTitle,
      productImageUrl: productImageUrl,
    );
  }
}

class SendMessageUseCase {
  final ChatRepository _repository;
  const SendMessageUseCase(this._repository);

  Future<Either<Failure, MessageEntity>> call({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    String? replyToContent,
  }) {
    return _repository.sendMessage(
      chatId: chatId,
      content: content,
      type: type,
      replyToMessageId: replyToMessageId,
      replyToContent: replyToContent,
    );
  }
}

class SendImageMessageUseCase {
  final ChatRepository _repository;
  const SendImageMessageUseCase(this._repository);

  Future<Either<Failure, MessageEntity>> call({
    required String chatId,
    required File image,
  }) {
    return _repository.sendImageMessage(chatId: chatId, image: image);
  }
}

class GetUserChatsUseCase {
  final ChatRepository _repository;
  const GetUserChatsUseCase(this._repository);

  Future<Either<Failure, List<ChatEntity>>> call(String userId) {
    return _repository.getUserChats(userId);
  }
}

class MarkMessagesReadUseCase {
  final ChatRepository _repository;
  const MarkMessagesReadUseCase(this._repository);

  Future<Either<Failure, void>> call(String chatId, String userId) {
    return _repository.markMessagesAsRead(chatId, userId);
  }
}
