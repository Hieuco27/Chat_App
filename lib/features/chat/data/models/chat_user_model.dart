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
      uid: json['uid'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      email: json['email'],
      isOnline: json['isOnline'],
      createAt: DateTime.parse(json['createAt']),
      lastSeen: DateTime.parse(json['lastSeen']),
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
    final data = doc.data() as Map<String, dynamic>;
    return ChatUserModel(
      uid: doc.id,
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      email: data['email'],
      isOnline: data['isOnline'],
      createAt: (data['createAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
