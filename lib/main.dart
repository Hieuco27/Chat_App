import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthRepository>(create: (_) => authRepository),
            RepositoryProvider<ChatRepository>(create: (_) => chatRepository),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    AuthBloc(authRepository: context.read<AuthRepository>())
                      ..add(AuthCheckRequested()),
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
