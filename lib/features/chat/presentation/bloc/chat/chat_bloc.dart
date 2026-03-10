import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/repository/chat_repository.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  ChatBloc(this._chatRepository)
    : super(
        ChatState(
          messages: const [],
          status: ChatStatus.initial,
          errorMessage: '',
        ),
      ) {
    on<ChatStart>(_onChatStart);
    on<ChatSendMessage>(_onMessageSent);
    on<ChatReceiveMessage>(_onMessageReceived);
  }

  Future<void> _onChatStart(ChatStart event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      // Kết nối socket + join room
      await _chatRepository.initChat(
        userId: event.userId,
        roomId: event.roomId,
      );
      // Lắng nghe tin nhắn
      _chatRepository.receiveMessage().listen((message) {
        add(ChatReceiveMessage(message: message));
      });
      //Load tin nhắn cũ từ firebase
      await emit.forEach(
        _chatRepository.getMessages(event.roomId),
        onData: (messages) =>
            state.copyWith(messages: messages, status: ChatStatus.loaded),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void _onMessageSent(ChatSendMessage event, Emitter<ChatState> emit) {
    // 1. Gửi qua socket/firestore
    _chatRepository.sendMessage(event.message);

    // 2. Cập nhật UI ngay lập tức
    final updatedMessages = List<ChatMessageEntity>.from(state.messages)
      ..add(event.message);
    emit(state.copyWith(messages: updatedMessages));
  }

  void _onMessageReceived(ChatReceiveMessage event, Emitter<ChatState> emit) {
    // Cập nhật danh sách khi có tin mới từ người khác
    final updatedMessages = List<ChatMessageEntity>.from(state.messages)
      ..add(event.message);
    emit(state.copyWith(messages: updatedMessages));
  }
}
