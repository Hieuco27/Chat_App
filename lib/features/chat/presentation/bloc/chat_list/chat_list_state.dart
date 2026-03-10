import 'package:chat_app/features/chat/domain/entities/chat_room.dart';
import 'package:equatable/equatable.dart';

sealed class ChatListState extends Equatable {
  const ChatListState();
  @override
  List<Object?> get props => [];
}

class ChatListInitial extends ChatListState {
  const ChatListInitial();
  @override
  List<Object?> get props => [];
}

class ChatListLoading extends ChatListState {
  const ChatListLoading();
  @override
  List<Object?> get props => [];
}

class ChatListLoaded extends ChatListState {
  final List<ChatRoomEntity> rooms;
  const ChatListLoaded({required this.rooms});
  @override
  List<Object?> get props => [rooms];
}

class ChatListError extends ChatListState {
  final String errorMessage;
  const ChatListError({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}
