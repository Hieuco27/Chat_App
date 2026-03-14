import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String receiverId;
  final String type;
  final Map<String, dynamic> data;
  final bool isSeen;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.receiverId,
    this.type = 'chat',
    this.data = const {},
    this.isSeen = false,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? content,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? receiverId,
    String? type,
    Map<String, dynamic>? data,
    bool? isSeen,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      data: data ?? this.data,
      isSeen: isSeen ?? this.isSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    senderId,
    senderName,
    senderAvatar,
    receiverId,
    type,
    data,
    isSeen,
    createdAt,
  ];
}
