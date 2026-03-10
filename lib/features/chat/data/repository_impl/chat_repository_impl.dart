import 'dart:async';

import 'package:chat_app/features/chat/data/datasource/chat_remote_datasource.dart';
import 'package:chat_app/features/chat/data/datasource/chat_socket_datasource.dart';
import 'package:chat_app/features/chat/data/models/chat_message_model.dart';
import 'package:chat_app/features/chat/data/models/chat_room_model.dart';
import 'package:chat_app/features/chat/data/models/chat_user_model.dart';
import 'package:chat_app/features/chat/domain/entities/chat_message.dart';
import 'package:chat_app/features/chat/domain/entities/chat_room.dart';
import 'package:chat_app/features/chat/domain/entities/chat_user.dart';
import 'package:chat_app/features/chat/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatSocketDatasource _socketDatasource;
  final ChatRemoteDatasource _remoteDatasource;

  // StreamController để chuyển callback từ SocketDatasource thành Stream
  final StreamController<ChatMessageEntity> _messageController =
      StreamController<ChatMessageEntity>.broadcast();

  ChatRepositoryImpl({
    required ChatSocketDatasource socketDatasource,
    required ChatRemoteDatasource remoteDatasource,
  }) : _socketDatasource = socketDatasource,
       _remoteDatasource = remoteDatasource;

  // ========================
  // KẾT NỐI SOCKET
  // ========================

  /// Kết nối socket và lắng nghe tin nhắn
  void connect({
    required String userId,
    required Function(ChatMessageModel) onMessageReceived,
  }) {
    _socketDatasource.connect(
      userId: userId,
      onMessageReceived: (message) {
        // 1. Gửi vào stream để Bloc có thể listen
        _messageController.add(message);
        // 2. Callback trực tiếp (nếu cần)
        onMessageReceived(message);
      },
    );
  }

  /// Tham gia vào phòng chat
  void joinRoom(String roomId) {
    _socketDatasource.joinRoom(roomId);
  }

  /// Rời phòng chat
  void leaveRoom(String roomId) {
    _socketDatasource.leaveRoom(roomId);
  }

  // ========================
  // ROOM - Firestore
  // ========================

  /// Khởi tạo kết nối 1 phòng room
  @override
  Future<void> initChat({
    required String userId,
    required String roomId,
  }) async {
    _socketDatasource.connect(
      userId: userId,
      onMessageReceived: (message) {
        _messageController.add(message);
      },
    );
    _socketDatasource.joinRoom(roomId);
  }

  /// Lấy danh sách phòng chat của user từ Firestore
  @override
  Stream<List<ChatRoomEntity>> getRooms(String userId) {
    return _remoteDatasource.getRooms(userId).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Gán id từ document
        return ChatRoomModel.fromJson(data);
      }).toList();
    });
  }

  /// Tạo phòng chat mới trên Firestore
  @override
  Future<void> createRoom(List<String> participants) async {
    await _remoteDatasource.createRoom(participants);
  }

  // ========================
  // MESSAGE
  // ========================

  /// Lấy danh sách tin nhắn trong phòng chat từ Firestore
  @override
  Stream<List<ChatMessageEntity>> getMessages(String roomId) {
    return _remoteDatasource.getMessages(roomId).map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessageModel.fromFirestore(doc);
      }).toList();
    });
  }

  /// Gửi tin nhắn qua Socket + lưu vào Firestore
  @override
  Future<void> sendMessage(ChatMessageEntity message) async {
    // 1. Gửi qua Socket (realtime)
    final messageModel = ChatMessageModel(
      id: message.id,
      senderId: message.senderId,
      content: message.content,
      createAt: message.createAt,
      roomId: message.roomId,
      isRead: message.isRead,
    );
    _socketDatasource.sendMessage(messageModel);

    // 2. Lưu vào Firestore (persistent)
    await _remoteDatasource.sendMessage(
      message.roomId,
      message.senderId,
      message.content,
    );
  }

  /// Stream nhận tin nhắn realtime từ Socket
  @override
  Stream<ChatMessageEntity> receiveMessage() {
    return _messageController.stream;
  }

  // ========================
  // USER - Firestore
  // ========================

  /// Lấy thông tin user từ Firestore
  @override
  Future<ChatUserEntity> getUser(String userId) async {
    final doc = await _remoteDatasource.getUser(userId);
    return ChatUserModel.fromFirestore(doc);
  }

  /// Tìm kiếm user từ Firestore
  @override
  Future<List<ChatUserEntity>> searchUsers(String query) async {
    final snapshot = await _remoteDatasource.searchUsers(query);
    return snapshot.docs.map((doc) {
      return ChatUserModel.fromFirestore(doc);
    }).toList();
  }

  // ========================
  // DISPOSE
  // ========================

  /// Giải phóng tài nguyên
  void dispose() {
    _socketDatasource.dispose();
    _messageController.close();
  }
}
