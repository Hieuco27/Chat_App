import 'package:chat_app/features/chat/domain/repository/chat_repository.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_list/chat_list_event.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_list/chat_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository chatRepository;
  ChatListBloc({required this.chatRepository}) : super(ChatListInitial()) {
    on<ChatListStarted>(_onStarted);
    on<ChatListCreateRoom>(_onCreateRoom);
    on<ChatListSearchUsers>(_onSearchUsers);
  }

  Future<void> _onStarted(
    ChatListStarted event,
    Emitter<ChatListState> emit,
  ) async {
    emit(const ChatListLoading());
    try {
      await emit.forEach(
        chatRepository.getRooms(event.userId),
        onData: (rooms) => ChatListLoaded(rooms: rooms),
        onError: (error, _) => ChatListError(errorMessage: error.toString()),
      );
    } catch (e) {
      emit(ChatListError(errorMessage: e.toString()));
    }
  }

  // Tạo room mới
  Future<void> _onCreateRoom(
    ChatListCreateRoom event,
    Emitter<ChatListState> emit,
  ) async {
    try {
      await chatRepository.createRoom(event.participants);
    } catch (e) {
      emit(ChatListError(errorMessage: e.toString()));
    }
  }

  Future<void> _onSearchUsers(
    ChatListSearchUsers event,
    Emitter<ChatListState> emit,
  ) async {
    try {
      // TODO: emit state với kết quả search
      await chatRepository.searchUsers(event.query);
    } catch (e) {
      emit(ChatListError(errorMessage: e.toString()));
    }
  }
}
