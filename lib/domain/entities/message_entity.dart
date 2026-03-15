import 'package:equatable/equatable.dart';

enum MessageType { text, image, system }

enum MessageStatus { sending, sent, delivered, read, failed }

class MessageEntity extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final String? replyToMessageId;
  final String? replyToContent;
  final bool isOffline;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.replyToMessageId,
    this.replyToContent,
    this.isOffline = false,
  });

  MessageEntity copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
    String? replyToMessageId,
    String? replyToContent,
    bool? isOffline,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToContent: replyToContent ?? this.replyToContent,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [id, chatId, senderId, content, createdAt];
}

class ChatEntity extends Equatable {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantAvatars;
  final String? lastMessage;
  final MessageType? lastMessageType;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCounts;
  final String? productId;
  final String? productTitle;
  final String? productImageUrl;
  final DateTime createdAt;
  final bool isActive;

  const ChatEntity({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantAvatars,
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.unreadCounts = const {},
    this.productId,
    this.productTitle,
    this.productImageUrl,
    required this.createdAt,
    this.isActive = true,
  });

  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  String getOtherParticipantName(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantNames[otherId] ?? 'Unknown User';
  }

  String? getOtherParticipantAvatar(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantAvatars[otherId];
  }

  int getUnreadCount(String userId) => unreadCounts[userId] ?? 0;

  @override
  List<Object?> get props => [id, participantIds, lastMessageAt];
}
