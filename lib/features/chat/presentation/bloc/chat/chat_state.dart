import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

enum ChatStatus { initial, loading, loaded, error, sendMessage, receiveMessage }

class ChatState extends Equatable {
  final List<ChatMessageEntity> messages;
  final ChatStatus status;
  final String errorMessage;
  const ChatState({
    required this.messages,
    required this.status,
    required this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessageEntity>? messages,
    ChatStatus? status,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, status, errorMessage];
}
