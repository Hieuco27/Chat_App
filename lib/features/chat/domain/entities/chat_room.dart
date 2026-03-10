import 'package:chat_app/features/chat/domain/entities/chat_user.dart';

class ChatRoomEntity {
  final String id;
  final List<String> participants; // người tham gia
  final String lastMessageContent;
  final String lastMessageSenderId;
  final DateTime updatedAt;
  final DateTime createdAt;
  final Map<String, ChatUserEntity> userProfiles;

  ChatRoomEntity({
    required this.id,
    required this.participants,
    required this.lastMessageContent,
    required this.lastMessageSenderId,
    required this.updatedAt,
    required this.createdAt,
    required this.userProfiles,
  });
}
