import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:chat_app/features/auth/domain/entities/auth_user_entity.dart';

/// Model chuyển đổi từ Firebase User → AuthUserEntity
/// Chỉ tồn tại ở data layer
class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
  });

  /// Tạo từ Firebase Auth User object
  factory AuthUserModel.fromFirebaseUser(firebase.User user) {
    return AuthUserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoUrl: user.photoURL ?? '',
    );
  }

  /// Tạo từ Firestore document
  factory AuthUserModel.fromFirebase(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuthUserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? data['name'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  /// Chuyển thành Map để lưu Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }
}
