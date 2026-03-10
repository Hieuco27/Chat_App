import 'package:equatable/equatable.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthUserEntity? user;
  final String errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage = '',
  });

  /// Truy cập nhanh thông tin user
  String? get userId => user?.uid;
  String? get email => user?.email;
  String? get displayName => user?.displayName;

  AuthState copyWith({
    AuthStatus? status,
    AuthUserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
