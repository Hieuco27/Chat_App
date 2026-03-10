import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  /// Kiểm tra trạng thái đăng nhập khi mở app
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  /// Đăng nhập bằng Email
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _mapAuthError(e.code),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đã xảy ra lỗi: ${e.toString()}',
        ),
      );
    }
  }

  /// Đăng ký tài khoản mới
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.signUpWithEmail(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _mapAuthError(e.code),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đã xảy ra lỗi: ${e.toString()}',
        ),
      );
    }
  }

  /// Đăng nhập bằng Google
  Future<void> _onGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đăng nhập Google thất bại: ${e.toString()}',
        ),
      );
    }
  }

  /// Đăng xuất
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Map mã lỗi Firebase thành thông báo tiếng Việt
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      default:
        return 'Đã xảy ra lỗi xác thực.';
    }
  }
}
