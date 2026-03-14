import 'package:chat_app/features/notification/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<void> initialize();

  /// Lấy FCM token hiện tại
  Future<String?> getFCMToken();

  /// Stream lắng nghe khi FCM token thay đổi
  Stream<String> get onTokenRefresh;

  /// Lưu FCM token lên server/Firestore
  Future<void> saveTokenToServer(String userId, String token);

  /// Xoá FCM token khi đăng xuất
  Future<void> removeTokenFromServer(String userId);

  /// Stream lắng nghe notification khi app đang mở (foreground)
  Stream<NotificationEntity> get onForegroundMessage;

  /// Xử lý khi user tap vào notification
  Stream<NotificationEntity> get onMessageOpenedApp;

  /// Gửi notification tới user cụ thể (thông qua server/Cloud Function)
  Future<void> sendNotification({
    required String receiverId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic> data,
  });

  /// Lấy danh sách notifications từ Firestore
  Future<List<NotificationEntity>> getNotifications(String userId);

  /// Đánh dấu notification đã đọc
  Future<void> markAsRead(String notificationId);

  /// Đánh dấu tất cả notification đã đọc
  Future<void> markAllAsRead(String userId);

  /// Xoá notification
  Future<void> deleteNotification(String notificationId);

  /// Đếm số notification chưa đọc
  Future<int> getUnreadCount(String userId);

  /// Stream lắng nghe realtime số notification chưa đọc
  Stream<int> watchUnreadCount(String userId);
}
