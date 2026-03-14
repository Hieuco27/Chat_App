import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

// Event khởi tạo
class ChatStart extends ChatEvent {
  final String userId;
  final String roomId;
  const ChatStart({required this.userId, required this.roomId});
  @override
  List<Object?> get props => [userId, roomId];
}

// Event gửi tin nhắn
class ChatSendMessage extends ChatEvent {
  final ChatMessageEntity message;
  const ChatSendMessage({required this.message});
  @override
  List<Object?> get props => [message];
}

// Event gửi tin nhắn media (ảnh, video, ghi âm) cần upload file
class ChatSendMediaMessage extends ChatEvent {
  final ChatMessageEntity message;
  final File file;
  final String pathFolder;

  const ChatSendMediaMessage({
    required this.message,
    required this.file,
    required this.pathFolder,
  });

  @override
  List<Object?> get props => [message, file, pathFolder];
}

// Event nhận tin nhắn
class ChatReceiveMessage extends ChatEvent {
  final ChatMessageEntity message;
  const ChatReceiveMessage({required this.message});
  @override
  List<Object?> get props => [message];
}
