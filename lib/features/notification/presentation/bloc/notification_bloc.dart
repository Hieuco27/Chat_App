import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/features/notification/domain/repository/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  StreamSubscription? _foregroundMessageSubscription;
  StreamSubscription? _messageOpenedAppSubscription;
  StreamSubscription? _tokenRefreshSubscription;

  NotificationBloc({required NotificationRepository notificationRepository})
    : _notificationRepository = notificationRepository,
      super(const NotificationState()) {
    on<NotificationInitRequested>(_onInitRequested);
    on<NotificationSaveTokenRequested>(_onSaveTokenRequested);
    on<NotificationRemoveTokenRequested>(_onRemoveTokenRequested);
    on<NotificationTokenRefreshed>(_onTokenRefreshed);
    on<NotificationReceived>(_onNotificationReceived);
    on<NotificationTapped>(_onNotificationTapped);
    on<NotificationListRequested>(_onListRequested);
    on<NotificationMarkAsReadRequested>(_onMarkAsReadRequested);
    on<NotificationMarkAllAsReadRequested>(_onMarkAllAsReadRequested);
    on<NotificationDeleteRequested>(_onDeleteRequested);
  }

  /// Khởi tạo FCM, lấy token, setup listeners
  Future<void> _onInitRequested(
    NotificationInitRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Khởi tạo FCM
      await _notificationRepository.initialize();

      // Lấy FCM token
      final token = await _notificationRepository.getFCMToken();
      emit(state.copyWith(fcmToken: token));

      // Lắng nghe foreground messages
      _foregroundMessageSubscription = _notificationRepository
          .onForegroundMessage
          .listen((notification) {
            add(
              NotificationReceived(
                title: notification.title,
                content: notification.content,
                data: notification.data,
              ),
            );
          });

      // Lắng nghe khi user tap notification
      _messageOpenedAppSubscription = _notificationRepository.onMessageOpenedApp
          .listen((notification) {
            add(NotificationTapped(data: notification.data));
          });

      // Lắng nghe token refresh
      _tokenRefreshSubscription = _notificationRepository.onTokenRefresh.listen(
        (newToken) {
          add(NotificationTokenRefreshed(token: newToken));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: 'Khởi tạo notification thất bại: ${e.toString()}',
        ),
      );
    }
  }

  /// Lưu FCM token lên server
  Future<void> _onSaveTokenRequested(
    NotificationSaveTokenRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final token =
          state.fcmToken ?? await _notificationRepository.getFCMToken();
      if (token != null) {
        await _notificationRepository.saveTokenToServer(event.userId, token);
        emit(state.copyWith(fcmToken: token));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Lưu token thất bại: ${e.toString()}'));
    }
  }

  /// Xoá FCM token khi đăng xuất
  Future<void> _onRemoveTokenRequested(
    NotificationRemoveTokenRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.removeTokenFromServer(event.userId);
      emit(const NotificationState()); // Reset state
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Xoá token thất bại: ${e.toString()}'));
    }
  }

  /// Khi token được refresh
  Future<void> _onTokenRefreshed(
    NotificationTokenRefreshed event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(fcmToken: event.token));
  }

  /// Khi nhận notification ở foreground
  Future<void> _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    // Tăng unread count
    emit(state.copyWith(unreadCount: state.unreadCount + 1));
  }

  /// Khi user tap vào notification
  Future<void> _onNotificationTapped(
    NotificationTapped event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(tappedNotificationData: event.data));
  }

  /// Lấy danh sách notifications
  Future<void> _onListRequested(
    NotificationListRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    try {
      final notifications = await _notificationRepository.getNotifications(
        event.userId,
      );
      final unreadCount = await _notificationRepository.getUnreadCount(
        event.userId,
      );
      emit(
        state.copyWith(
          status: NotificationStatus.loaded,
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: 'Lấy danh sách thất bại: ${e.toString()}',
        ),
      );
    }
  }

  /// Đánh dấu đã đọc
  Future<void> _onMarkAsReadRequested(
    NotificationMarkAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.markAsRead(event.notificationId);

      // Cập nhật local state
      final updatedList = state.notifications.map((n) {
        if (n.id == event.notificationId) {
          return n.copyWith(isSeen: true);
        }
        return n;
      }).toList();

      emit(
        state.copyWith(
          notifications: updatedList,
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Đánh dấu đã đọc thất bại: ${e.toString()}',
        ),
      );
    }
  }

  /// Đánh dấu tất cả đã đọc
  Future<void> _onMarkAllAsReadRequested(
    NotificationMarkAllAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.markAllAsRead(event.userId);

      final updatedList = state.notifications
          .map((n) => n.copyWith(isSeen: true))
          .toList();

      emit(state.copyWith(notifications: updatedList, unreadCount: 0));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Đánh dấu tất cả đã đọc thất bại: ${e.toString()}',
        ),
      );
    }
  }

  /// Xoá notification
  Future<void> _onDeleteRequested(
    NotificationDeleteRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.deleteNotification(event.notificationId);

      final deletedNotification = state.notifications.firstWhere(
        (n) => n.id == event.notificationId,
      );

      final updatedList = state.notifications
          .where((n) => n.id != event.notificationId)
          .toList();

      emit(
        state.copyWith(
          notifications: updatedList,
          unreadCount: !deletedNotification.isSeen && state.unreadCount > 0
              ? state.unreadCount - 1
              : state.unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Xoá notification thất bại: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _foregroundMessageSubscription?.cancel();
    _messageOpenedAppSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    return super.close();
  }
}
