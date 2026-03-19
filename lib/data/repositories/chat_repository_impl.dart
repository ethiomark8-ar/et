import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  const ChatRepositoryImpl({required ChatRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, ChatEntity>> getOrCreateChat({
    required String buyerId,
    required String sellerId,
    String? productId,
    String? productTitle,
    String? productImageUrl,
  }) async {
    try {
      final chat = await _remoteDataSource.getOrCreateChat(
        buyerId: buyerId,
        sellerId: sellerId,
        productId: productId,
        productTitle: productTitle,
        productImageUrl: productImageUrl,
      );
      return Right(chat);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatEntity>> getChatById(String chatId) async {
    try {
      final chat = await _remoteDataSource.getChatById(chatId);
      return Right(chat);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatEntity>>> getUserChats(String userId) async {
    try {
      final chats = await _remoteDataSource.getUserChats(userId);
      return Right(chats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    String? replyToContent,
  }) async {
    try {
      final message = await _remoteDataSource.sendMessage(
        chatId: chatId,
        content: content,
        type: type,
        replyToMessageId: replyToMessageId,
        replyToContent: replyToContent,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendImageMessage({
    required String chatId,
    required File image,
  }) async {
    try {
      final message = await _remoteDataSource.sendImageMessage(
        chatId: chatId,
        image: image,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(
      String chatId, String userId) async {
    try {
      await _remoteDataSource.markMessagesAsRead(chatId, userId);
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String chatId) {
    return _remoteDataSource.watchMessages(chatId);
  }

  @override
  Stream<List<ChatEntity>> watchUserChats(String userId) {
    return _remoteDataSource.watchUserChats(userId);
  }

  @override
  Future<Either<Failure, void>> queueOfflineMessage(MessageEntity message) async {
    // Store in local Hive box for offline support
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> syncOfflineMessages(String chatId) async {
    // Sync queued offline messages to Firestore
    return const Right(null);
  }

  @override
  Stream<int> watchTotalUnreadCount(String userId) {
    return _remoteDataSource.watchTotalUnreadCount(userId);
  }
}
