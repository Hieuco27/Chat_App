import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Khởi tạo FCM khi app start
class NotificationInitRequested extends NotificationEvent {}

/// Khi FCM token thay đổi
class NotificationTokenRefreshed extends NotificationEvent {
  final String token;

  const NotificationTokenRefreshed({required this.token});

  @override
  List<Object?> get props => [token];
}

/// Lưu FCM token lên server
class NotificationSaveTokenRequested extends NotificationEvent {
  final String userId;

  const NotificationSaveTokenRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Xoá FCM token khi đăng xuất
class NotificationRemoveTokenRequested extends NotificationEvent {
  final String userId;

  const NotificationRemoveTokenRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Nhận notification foreground
class NotificationReceived extends NotificationEvent {
  final String title;
  final String content;
  final Map<String, dynamic> data;

  const NotificationReceived({
    required this.title,
    required this.content,
    this.data = const {},
  });

  @override
  List<Object?> get props => [title, content, data];
}

/// Khi user tap notification
class NotificationTapped extends NotificationEvent {
  final Map<String, dynamic> data;

  const NotificationTapped({required this.data});

  @override
  List<Object?> get props => [data];
}

/// Lấy danh sách notifications
class NotificationListRequested extends NotificationEvent {
  final String userId;

  const NotificationListRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Đánh dấu notification đã đọc
class NotificationMarkAsReadRequested extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsReadRequested({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Đánh dấu tất cả đã đọc
class NotificationMarkAllAsReadRequested extends NotificationEvent {
  final String userId;

  const NotificationMarkAllAsReadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Xoá notification
class NotificationDeleteRequested extends NotificationEvent {
  final String notificationId;

  const NotificationDeleteRequested({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}
