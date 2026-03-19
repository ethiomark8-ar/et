import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/message_model.dart';
import '../../../domain/entities/message_entity.dart';

abstract class ChatRemoteDataSource {
  Future<ChatModel> getOrCreateChat({
    required String buyerId,
    required String sellerId,
    String? productId,
    String? productTitle,
    String? productImageUrl,
  });
  Future<ChatModel> getChatById(String chatId);
  Future<List<ChatModel>> getUserChats(String userId);
  Future<MessageModel> sendMessage({
    required String chatId,
    required String content,
    MessageType type,
    String? replyToMessageId,
    String? replyToContent,
  });
  Future<MessageModel> sendImageMessage({required String chatId, required File image});
  Future<void> markMessagesAsRead(String chatId, String userId);
  Stream<List<MessageModel>> watchMessages(String chatId);
  Stream<List<ChatModel>> watchUserChats(String userId);
  Stream<int> watchTotalUnreadCount(String userId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final Uuid _uuid;

  ChatRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required FirebaseAuth auth,
    Uuid? uuid,
  })  : _firestore = firestore,
        _storage = storage,
        _auth = auth,
        _uuid = uuid ?? const Uuid();

  CollectionReference get _chatsRef =>
      _firestore.collection(AppConstants.chatsCollection);

  @override
  Future<ChatModel> getOrCreateChat({
    required String buyerId,
    required String sellerId,
    String? productId,
    String? productTitle,
    String? productImageUrl,
  }) async {
    try {
      // Check if chat already exists
      final existingSnapshot = await _chatsRef
          .where('participantIds', arrayContains: buyerId)
          .get();

      final existingChat = existingSnapshot.docs
          .cast<DocumentSnapshot<Map<String, dynamic>>>()
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) return false;
            final ids = List<String>.from(data['participantIds'] as List? ?? []);
            return ids.contains(sellerId) &&
                (productId == null || data['productId'] == productId);
          })
          .map((doc) => ChatModel.fromFirestore(doc))
          .firstOrNull;

      if (existingChat != null) return existingChat;

      // Create new chat
      final buyerDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(buyerId)
          .get();
      final sellerDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(sellerId)
          .get();

      final buyerData = buyerDoc.data() as Map<String, dynamic>? ?? {};
      final sellerData = sellerDoc.data() as Map<String, dynamic>? ?? {};

      final now = DateTime.now();
      final chatRef = _chatsRef.doc();

      final chatModel = ChatModel(
        id: chatRef.id,
        participantIds: [buyerId, sellerId],
        participantNames: {
          buyerId: buyerData['fullName'] as String? ?? 'Buyer',
          sellerId: sellerData['fullName'] as String? ?? 'Seller',
        },
        participantAvatars: {
          buyerId: buyerData['avatarUrl'] as String?,
          sellerId: sellerData['avatarUrl'] as String?,
        },
        unreadCounts: {buyerId: 0, sellerId: 0},
        productId: productId,
        productTitle: productTitle,
        productImageUrl: productImageUrl,
        createdAt: now,
      );

      await chatRef.set(chatModel.toMap());
      return chatModel;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to create chat', code: e.code);
    }
  }

  @override
  Future<ChatModel> getChatById(String chatId) async {
    try {
      final doc = await _chatsRef.doc(chatId).get();
      if (!doc.exists) throw const NotFoundException(message: 'Chat not found');
      return ChatModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    } on NotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get chat', code: e.code);
    }
  }

  @override
  Future<List<ChatModel>> getUserChats(String userId) async {
    try {
      final snapshot = await _chatsRef
          .where('participantIds', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('lastMessageAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get chats', code: e.code);
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    String? replyToContent,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw const AuthException(message: 'Not authenticated');

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};

      final messageRef = _chatsRef.doc(chatId).collection(AppConstants.messagesCollection).doc();
      final now = DateTime.now();

      final message = MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: userId,
        senderName: userData['fullName'] as String? ?? 'Unknown',
        senderAvatarUrl: userData['avatarUrl'] as String?,
        content: content,
        type: type,
        status: MessageStatus.sent,
        createdAt: now,
        replyToMessageId: replyToMessageId,
        replyToContent: replyToContent,
      );

      final batch = _firestore.batch();
      batch.set(messageRef, message.toMap());

      // Update chat's last message
      final chatRef = _chatsRef.doc(chatId);
      final chatDoc = await chatRef.get();
      if (chatDoc.exists) {
        final chatData = chatDoc.data() as Map<String, dynamic>? ?? {};
        final participantIds = List<String>.from(chatData['participantIds'] as List? ?? []);
        final otherUserId = participantIds.firstWhere((id) => id != userId, orElse: () => '');

        batch.update(chatRef, {
          'lastMessage': content,
          'lastMessageType': type.name,
          'lastMessageSenderId': userId,
          'lastMessageAt': Timestamp.fromDate(now),
          if (otherUserId.isNotEmpty) 'unreadCounts.$otherUserId': FieldValue.increment(1),
        });
      }

      await batch.commit();
      return message;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to send message', code: e.code);
    }
  }

  @override
  Future<MessageModel> sendImageMessage({
    required String chatId,
    required File image,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw const AuthException(message: 'Not authenticated');

      final imageId = _uuid.v4();
      final imageRef = _storage.ref().child(
            '${AppConstants.chatsStoragePath}/$chatId/$imageId.jpg',
          );
      await imageRef.putFile(image);
      final imageUrl = await imageRef.getDownloadURL();

      return sendMessage(
        chatId: chatId,
        content: '📷 Image',
        type: MessageType.image,
      ).then((msg) => MessageModel(
            id: msg.id,
            chatId: msg.chatId,
            senderId: msg.senderId,
            senderName: msg.senderName,
            senderAvatarUrl: msg.senderAvatarUrl,
            content: msg.content,
            type: MessageType.image,
            status: msg.status,
            createdAt: msg.createdAt,
            imageUrl: imageUrl,
          ));
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to send image', code: e.code);
    }
  }

  @override
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      await _chatsRef.doc(chatId).update({
        'unreadCounts.$userId': 0,
      });

      // Mark individual messages as read
      final unreadMessages = await _chatsRef
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true, 'status': MessageStatus.read.name});
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to mark messages as read', code: e.code);
    }
  }

  @override
  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _chatsRef
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<ChatModel>> watchUserChats(String userId) {
    return _chatsRef
        .where('participantIds', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ChatModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  @override
  Stream<int> watchTotalUnreadCount(String userId) {
    return _chatsRef
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final unreadCounts = data['unreadCounts'] as Map<String, dynamic>? ?? {};
        total += (unreadCounts[userId] as int?) ?? 0;
      }
      return total;
    });
  }
}

extension _Iterables<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
