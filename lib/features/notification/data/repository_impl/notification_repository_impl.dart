import 'package:chat_app/features/notification/data/datasource/notification_remote_datasource.dart';
import 'package:chat_app/features/notification/data/models/notification_model.dart';
import 'package:chat_app/features/notification/domain/entities/notification_entity.dart';
import 'package:chat_app/features/notification/domain/repository/notification_repository.dart';

/// Implementation của NotificationRepository
/// Gọi NotificationRemoteDatasource → chuyển đổi FCM/Firestore data thành Entity
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource _remoteDatasource;

  NotificationRepositoryImpl({
    required NotificationRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  @override
  Future<void> initialize() async {
    await _remoteDatasource.initialize();
  }

  @override
  Future<String?> getFCMToken() async {
    return await _remoteDatasource.getToken();
  }

  @override
  Stream<String> get onTokenRefresh => _remoteDatasource.onTokenRefresh;

  @override
  Future<void> saveTokenToServer(String userId, String token) async {
    await _remoteDatasource.saveToken(userId, token);
  }

  @override
  Future<void> removeTokenFromServer(String userId) async {
    await _remoteDatasource.removeToken(userId);
  }

  @override
  Stream<NotificationEntity> get onForegroundMessage {
    return _remoteDatasource.onForegroundMessage.map((remoteMessage) {
      return NotificationModel.fromFCMData({
        'title': remoteMessage.notification?.title ?? '',
        'body': remoteMessage.notification?.body ?? '',
        ...remoteMessage.data,
      });
    });
  }

  @override
  Stream<NotificationEntity> get onMessageOpenedApp {
    return _remoteDatasource.onMessageOpenedApp.map((remoteMessage) {
      return NotificationModel.fromFCMData({
        'title': remoteMessage.notification?.title ?? '',
        'body': remoteMessage.notification?.body ?? '',
        ...remoteMessage.data,
      });
    });
  }

  @override
  Future<void> sendNotification({
    required String receiverId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic> data = const {},
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: body,
      senderId: '', // Sẽ được set bởi BLoC/UseCase
      senderName: '',
      senderAvatar: '',
      receiverId: receiverId,
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );
    await _remoteDatasource.saveNotification(notification);
  }

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) async {
    return await _remoteDatasource.getNotifications(userId);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _remoteDatasource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await _remoteDatasource.markAllAsRead(userId);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _remoteDatasource.deleteNotification(notificationId);
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return await _remoteDatasource.getUnreadCount(userId);
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _remoteDatasource.watchUnreadCount(userId);
  }
}
