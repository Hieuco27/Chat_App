import 'package:equatable/equatable.dart';

sealed class ChatListEvent extends Equatable {
  const ChatListEvent();
  @override
  List<Object?> get props => [];
}

class ChatListStarted extends ChatListEvent {
  final String userId;
  const ChatListStarted({required this.userId});
  @override
  List<Object?> get props => [userId];
}

// Tạo room mới
class ChatListCreateRoom extends ChatListEvent {
  final List<String> participants;
  const ChatListCreateRoom({required this.participants});
  @override
  List<Object?> get props => [participants];
}

// Tìm kiếm user
class ChatListSearchUsers extends ChatListEvent {
  final String query;
  const ChatListSearchUsers({required this.query});
  @override
  List<Object?> get props => [query];
}
