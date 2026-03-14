import 'dart:io';
import 'package:chat_app/features/chat/domain/entities/chat_message.dart';
import 'package:chat_app/features/chat/domain/entities/chat_room.dart';
import 'package:chat_app/features/chat/domain/entities/chat_user.dart';

abstract class ChatRepository {
  // Khởi tạo kết nối nối1 phòng room
  Future<void> initChat({required String userId, required String roomId});

  // lấy danh sách phòng chat
  Stream<List<ChatRoomEntity>> getRooms(String userId);

  // tạo 1 room mới khi bắt đầu cuộc trò chuyện
  Future<void> createRoom(List<String> participants);

  // lấy danh sách tin nhắn trong phòng chat
  Stream<List<ChatMessageEntity>> getMessages(String roomId);

  // gửi tin nhắn
  Future<void> sendMessage(ChatMessageEntity message);

  // nhận tin nhắn
  Stream<ChatMessageEntity> receiveMessage();

  // Lấy thông tin người dùng
  Future<ChatUserEntity> getUser(String userId);

  //tim kiếm user
  Future<List<ChatUserEntity>> searchUsers(String query);

  // Upload file
  Future<String> uploadFile(File file, String folder);
}
