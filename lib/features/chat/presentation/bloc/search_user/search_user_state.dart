import 'package:chat_app/features/chat/domain/entities/chat_user.dart';
import 'package:equatable/equatable.dart';

enum SearchUserStatus { initial, loading, success, error }

class SearchUserState extends Equatable {
  final SearchUserStatus status;
  final List<ChatUserEntity> users;
  final String errorMessage;

  const SearchUserState({
    this.status = SearchUserStatus.initial,
    this.users = const [],
    this.errorMessage = '',
  });

  SearchUserState copyWith({
    SearchUserStatus? status,
    List<ChatUserEntity>? users,
    String? errorMessage,
  }) {
    return SearchUserState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, errorMessage];
}
