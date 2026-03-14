enum MessageType { text, image, video, file, location, sticker, voice, system }

enum MessageStatus { sending, sent, error }

class ChatMessageEntity {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime createAt;
  final bool isRead;
  final MessageStatus status;
  final MessageType type;

  ChatMessageEntity({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.type,
    required this.content,
    required this.createAt,
    required this.isRead,
    this.status = MessageStatus.sent,
  });
}
