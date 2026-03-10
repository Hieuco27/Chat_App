import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Kiểm tra trạng thái đăng nhập khi mở app
class AuthCheckRequested extends AuthEvent {}

/// Đăng nhập bằng email + password
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Đăng ký tài khoản mới
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Đăng nhập bằng Google
class AuthGoogleLoginRequested extends AuthEvent {}

// Đăng nhập bằng Apple
class AuthAppleLoginRequested extends AuthEvent {}

/// Đăng xuất
class AuthLogoutRequested extends AuthEvent {}
