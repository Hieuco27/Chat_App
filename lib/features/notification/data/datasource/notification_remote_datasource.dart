import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chat_app/features/notification/data/models/notification_model.dart';

/// Datasource xử lý trực tiếp với Firebase Messaging & Firestore
class NotificationRemoteDatasource {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream controllers
  final StreamController<RemoteMessage> _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _messageOpenedAppController =
      StreamController<RemoteMessage>.broadcast();

  /// Khởi tạo FCM: request permission & setup listeners
  Future<void> initialize() async {
    // Request permission (iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Lắng nghe tin nhắn khi app đang mở (foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _foregroundMessageController.add(message);
      });

      // Lắng nghe khi user tap notification (app ở background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _messageOpenedAppController.add(message);
      });

      // Kiểm tra nếu app được mở từ terminated state bởi notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _messageOpenedAppController.add(initialMessage);
      }
    }
  }

  /// Lấy FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Stream lắng nghe khi token thay đổi
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Stream foreground messages
  Stream<RemoteMessage> get onForegroundMessage =>
      _foregroundMessageController.stream;

  /// Stream message opened app
  Stream<RemoteMessage> get onMessageOpenedApp =>
      _messageOpenedAppController.stream;

  /// Lưu FCM token vào Firestore
  Future<void> saveToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Xoá FCM token khỏi Firestore (khi đăng xuất)
  Future<void> removeToken(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': FieldValue.delete(),
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Lưu notification vào Firestore
  Future<void> saveNotification(NotificationModel notification) async {
    await _firestore
        .collection('notifications')
        .add(notification.toFirestore());
  }

  /// Lấy danh sách notifications từ Firestore
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();
  }

  /// Đánh dấu notification đã đọc
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  /// Đánh dấu tất cả notification đã đọc
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  /// Xoá notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  /// Đếm số notification chưa đọc
  Future<int> getUnreadCount(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }

  /// Stream realtime số notification chưa đọc
  Stream<int> watchUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Dispose stream controllers
  void dispose() {
    _foregroundMessageController.close();
    _messageOpenedAppController.close();
  }
}
