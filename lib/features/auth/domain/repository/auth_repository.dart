import 'package:chat_app/features/auth/domain/entities/auth_user_entity.dart';

/// Abstract repository — interface cho Auth
/// BLoC phụ thuộc vào interface này, KHÔNG phụ thuộc Firebase
abstract class AuthRepository {
  /// User hiện tại (null nếu chưa đăng nhập)
  AuthUserEntity? get currentUser;

  /// Stream lắng nghe thay đổi trạng thái auth
  Stream<AuthUserEntity?> get authStateChanges;

  /// Đăng nhập bằng Email & Password
  Future<AuthUserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Đăng ký bằng Email & Password
  Future<AuthUserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Đăng nhập bằng Google
  Future<AuthUserEntity> signInWithGoogle();

  /// Đăng nhập bằng Apple
  Future<AuthUserEntity> signInWithApple();

  /// Đăng xuất
  Future<void> signOut();
}
