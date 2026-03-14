import 'package:equatable/equatable.dart';
import 'package:chat_app/features/notification/domain/entities/notification_entity.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final String? fcmToken;
  final String errorMessage;

  /// Notification data khi user tap vào notification
  final Map<String, dynamic>? tappedNotificationData;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.fcmToken,
    this.errorMessage = '',
    this.tappedNotificationData,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? notifications,
    int? unreadCount,
    String? fcmToken,
    String? errorMessage,
    Map<String, dynamic>? tappedNotificationData,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      fcmToken: fcmToken ?? this.fcmToken,
      errorMessage: errorMessage ?? this.errorMessage,
      tappedNotificationData:
          tappedNotificationData ?? this.tappedNotificationData,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notifications,
    unreadCount,
    fcmToken,
    errorMessage,
    tappedNotificationData,
  ];
}
