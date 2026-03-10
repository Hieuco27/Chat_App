import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessageEntity {
  ChatMessageModel({
    required super.id,
    required super.senderId,
    required super.content,
    required super.createAt,
    required super.roomId,
    required super.isRead,
  });


  // Chuyển từ JSON (Socket) sang Model
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      createAt: json['createAt'] != null
          ? DateTime.parse(json['createAt'])
          : DateTime.now(),
      roomId: json['roomId'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }

  // Chuyển từ Model sang JSON (Gửi qua Socket/Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'createAt': createAt.toIso8601String(),
      'roomId': roomId,
      'isRead': isRead,
    };
  }

  // Chuyển từ Firestore Document sang Model
  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      roomId: data['roomId'] ?? '',
      content: data['content'] ?? '',
      createAt: (data['createAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}
