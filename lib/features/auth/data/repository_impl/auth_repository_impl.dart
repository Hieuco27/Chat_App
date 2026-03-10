import 'package:chat_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:chat_app/features/auth/data/models/auth_user_model.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user_entity.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';

/// Implementation của AuthRepository
/// Gọi AuthRemoteDatasource → chuyển đổi Firebase User thành AuthUserEntity
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl({required AuthRemoteDatasource remoteDatasource})
    : _remoteDatasource = remoteDatasource;

  @override
  AuthUserEntity? get currentUser {
    final firebaseUser = _remoteDatasource.currentUser;
    if (firebaseUser == null) return null;
    return AuthUserModel.fromFirebaseUser(firebaseUser);
  }

  @override
  Stream<AuthUserEntity?> get authStateChanges {
    return _remoteDatasource.authStateChanges.map((firebaseUser) {
      if (firebaseUser == null) return null;
      return AuthUserModel.fromFirebaseUser(firebaseUser);
    });
  }

  @override
  Future<AuthUserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _remoteDatasource.signInWithEmail(email, password);
    return AuthUserModel.fromFirebaseUser(credential.user!);
  }

  @override
  Future<AuthUserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _remoteDatasource.signUpWithEmail(
      email,
      password,
      displayName,
    );
    return AuthUserModel.fromFirebaseUser(credential.user!);
  }

  @override
  Future<AuthUserEntity> signInWithGoogle() async {
    final credential = await _remoteDatasource.signInWithGoogle();
    return AuthUserModel.fromFirebaseUser(credential.user!);
  }

  @override
  Future<AuthUserEntity> signInWithApple() async {
    final credential = await _remoteDatasource.signInWithApple();
    return AuthUserModel.fromFirebaseUser(credential.user!);
  }

  @override
  Future<void> signOut() async {
    await _remoteDatasource.signOut();
  }
}
