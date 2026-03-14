import 'package:chat_app/features/chat/domain/entities/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUserModel extends ChatUserEntity {
  ChatUserModel({
    required super.uid,
    required super.displayName,
    required super.photoUrl,
    required super.email,
    required super.isOnline,
    required super.createAt,
    required super.lastSeen,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      uid: json['uid'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      email: json['email'] ?? '',
      isOnline: json['isOnline'] ?? false,
      createAt: _parseDateTime(json['createAt']),
      lastSeen: _parseDateTime(json['lastSeen']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'email': email,
      'isOnline': isOnline,
      'createAt': createAt.toIso8601String(),
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  factory ChatUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatUserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      email: data['email'] ?? '',
      isOnline: data['isOnline'] ?? false,
      createAt: _parseDateTime(data['createAt']),
      lastSeen: _parseDateTime(data['lastSeen']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
