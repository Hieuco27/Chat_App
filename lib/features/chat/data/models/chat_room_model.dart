import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/features/chat/domain/entities/chat_room.dart';
import 'package:chat_app/features/chat/data/models/chat_user_model.dart';

class ChatRoomModel extends ChatRoomEntity {
  ChatRoomModel({
    required super.id,
    required super.participants,
    required super.lastMessageContent,
    required super.lastMessageSenderId,
    required super.updatedAt,
    required super.createdAt,
    required super.userProfiles,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      lastMessageContent: json['lastMessageContent'] ?? '',
      lastMessageSenderId: json['lastMessageSenderId'] ?? '',
      updatedAt: _parseDateTime(json['updatedAt']),
      createdAt: _parseDateTime(json['createdAt']),
      userProfiles:
          (json['userProfiles'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, ChatUserModel.fromJson(value)),
          ) ??
          {},
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }
}
