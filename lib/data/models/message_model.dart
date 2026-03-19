import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.senderName,
    super.senderAvatarUrl,
    required super.content,
    super.type,
    super.status,
    required super.createdAt,
    super.isRead,
    super.imageUrl,
    super.replyToMessageId,
    super.replyToContent,
    super.isOffline,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromMap(data, doc.id);
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      chatId: map['chatId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      senderAvatarUrl: map['senderAvatarUrl'] as String?,
      content: map['content'] as String? ?? '',
      type: _parseMessageType(map['type'] as String?),
      status: _parseMessageStatus(map['status'] as String?),
      createdAt: _parseTimestamp(map['createdAt']),
      isRead: map['isRead'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
      replyToMessageId: map['replyToMessageId'] as String?,
      replyToContent: map['replyToContent'] as String?,
      isOffline: false,
    );
  }

  Map<String, dynamic> toMap() => {
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatarUrl': senderAvatarUrl,
        'content': content,
        'type': type.name,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
        'isRead': isRead,
        'imageUrl': imageUrl,
        'replyToMessageId': replyToMessageId,
        'replyToContent': replyToContent,
      };

  static MessageType _parseMessageType(String? type) {
    return MessageType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => MessageType.text,
    );
  }

  static MessageStatus _parseMessageStatus(String? status) {
    return MessageStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => MessageStatus.sent,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.participantIds,
    required super.participantNames,
    required super.participantAvatars,
    super.lastMessage,
    super.lastMessageType,
    super.lastMessageSenderId,
    super.lastMessageAt,
    super.unreadCounts,
    super.productId,
    super.productTitle,
    super.productImageUrl,
    required super.createdAt,
    super.isActive,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel.fromMap(data, doc.id);
  }

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    final rawUnread = map['unreadCounts'] as Map<String, dynamic>?;
    final unreadCounts = rawUnread?.map(
          (key, value) => MapEntry(key, (value as int?) ?? 0),
        ) ??
        {};

    final rawNames = map['participantNames'] as Map<String, dynamic>?;
    final participantNames = rawNames?.map(
          (key, value) => MapEntry(key, value as String? ?? ''),
        ) ??
        {};

    final rawAvatars = map['participantAvatars'] as Map<String, dynamic>?;
    final participantAvatars = rawAvatars?.map(
          (key, value) => MapEntry(key, value as String?),
        ) ??
        {};

    return ChatModel(
      id: id,
      participantIds: List<String>.from(map['participantIds'] as List? ?? []),
      participantNames: participantNames,
      participantAvatars: participantAvatars,
      lastMessage: map['lastMessage'] as String?,
      lastMessageType: map['lastMessageType'] != null
          ? MessageType.values.firstWhere(
              (e) => e.name == map['lastMessageType'],
              orElse: () => MessageType.text,
            )
          : null,
      lastMessageSenderId: map['lastMessageSenderId'] as String?,
      lastMessageAt: map['lastMessageAt'] != null
          ? _parseTimestamp(map['lastMessageAt'])
          : null,
      unreadCounts: unreadCounts,
      productId: map['productId'] as String?,
      productTitle: map['productTitle'] as String?,
      productImageUrl: map['productImageUrl'] as String?,
      createdAt: _parseTimestamp(map['createdAt']),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'participantIds': participantIds,
        'participantNames': participantNames,
        'participantAvatars': participantAvatars,
        'lastMessage': lastMessage,
        'lastMessageType': lastMessageType?.name,
        'lastMessageSenderId': lastMessageSenderId,
        'lastMessageAt':
            lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
        'unreadCounts': unreadCounts,
        'productId': productId,
        'productTitle': productTitle,
        'productImageUrl': productImageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'isActive': isActive,
      };

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
