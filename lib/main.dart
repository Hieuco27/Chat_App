import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Auth
import 'package:chat_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:chat_app/features/auth/data/repository_impl/auth_repository_impl.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/features/auth/presentation/screen/login_screen.dart';

// Chat
import 'package:chat_app/features/chat/data/datasource/chat_remote_datasource.dart';
import 'package:chat_app/features/chat/data/datasource/chat_socket_datasource.dart';
import 'package:chat_app/features/chat/data/repository_impl/chat_repository_impl.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:chat_app/features/chat/presentation/screen/chat_list_screen/chat_list_screen.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:chat_app/features/chat/domain/repository/chat_repository.dart';

// Notification
import 'package:chat_app/features/notification/data/datasource/notification_remote_datasource.dart';
import 'package:chat_app/features/notification/data/repository_impl/notification_repository_impl.dart';
import 'package:chat_app/features/notification/domain/repository/notification_repository.dart';
import 'package:chat_app/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:chat_app/features/notification/presentation/bloc/notification_event.dart';

// Đặt hàm này ở cấp ngoài cùng (Top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo Auth dependencies
    final authDatasource = AuthRemoteDatasource();
    final authRepository = AuthRepositoryImpl(remoteDatasource: authDatasource);

    // Khởi tạo Chat dependencies
    final socketDatasource = ChatSocketDatasource();
    final remoteDatasource = ChatRemoteDatasource();
    final chatRepository = ChatRepositoryImpl(
      socketDatasource: socketDatasource,
      remoteDatasource: remoteDatasource,
    );

    // Khởi tạo Notification dependencies
    final notificationDatasource = NotificationRemoteDatasource();
    final notificationRepository = NotificationRepositoryImpl(
      remoteDatasource: notificationDatasource,
    );

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthRepository>(create: (_) => authRepository),
            RepositoryProvider<ChatRepository>(create: (_) => chatRepository),
            RepositoryProvider<NotificationRepository>(
              create: (_) => notificationRepository,
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    AuthBloc(authRepository: context.read<AuthRepository>())
                      ..add(AuthCheckRequested()),
              ),
              BlocProvider(
                create: (context) =>
                    NotificationBloc(
                      notificationRepository: context
                          .read<NotificationRepository>(),
                    )..add(
                      NotificationInitRequested(),
                    ), // Kích hoạt sự kiện Init để gọi initialize()
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.blue,
              ),
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  // Đã đăng nhập → ChatListScreen
                  if (state.status == AuthStatus.authenticated) {
                    // Nếu đã đăng nhập, bạn có thể gửi sự kiện cập nhật FCM Token lên server
                    // Thông qua: context.read<NotificationBloc>().add(NotificationSaveTokenRequested(userId: state.user!.id));
                    return BlocProvider(
                      create: (context) => ChatListBloc(
                        chatRepository: context.read<ChatRepository>(),
                      ),
                      child: const ChatListScreen(),
                    );
                  }

                  if (state.status == AuthStatus.initial ||
                      state.status == AuthStatus.loading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return const LoginScreen();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
