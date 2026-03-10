class ChatMessageEntity {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime createAt;
  final bool isRead;

  ChatMessageEntity({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createAt,
    required this.isRead,
  });
}
