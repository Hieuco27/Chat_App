import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/features/notification/domain/entities/notification_entity.dart';

/// Model chuyển đổi giữa Firestore data và NotificationEntity
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.content,
    required super.senderId,
    required super.senderName,
    required super.senderAvatar,
    required super.receiverId,
    super.type,
    super.data,
    super.isSeen,
    required super.createdAt,
  });

  /// Tạo NotificationModel từ Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderAvatar: data['senderAvatar'] ?? '',
      receiverId: data['receiverId'] ?? '',
      type: data['type'] ?? 'chat',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      isSeen: data['isSeen'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Tạo NotificationModel từ FCM RemoteMessage data
  factory NotificationModel.fromFCMData(Map<String, dynamic> messageData) {
    return NotificationModel(
      id:
          messageData['notificationId'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: messageData['title'] ?? '',
      content: messageData['body'] ?? messageData['content'] ?? '',
      senderId: messageData['senderId'] ?? '',
      senderName: messageData['senderName'] ?? '',
      senderAvatar: messageData['senderAvatar'] ?? '',
      receiverId: messageData['receiverId'] ?? '',
      type: messageData['type'] ?? 'chat',
      data: messageData,
      isSeen: false,
      createdAt: DateTime.now(),
    );
  }

  /// Chuyển đổi thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'receiverId': receiverId,
      'type': type,
      'data': data,
      'isSeen': isSeen,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
