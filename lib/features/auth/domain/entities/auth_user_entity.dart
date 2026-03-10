import 'package:equatable/equatable.dart';

/// Entity đại diện cho thông tin User trong Auth feature
/// Không phụ thuộc vào Firebase — đây là domain layer
class AuthUserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;

  const AuthUserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
