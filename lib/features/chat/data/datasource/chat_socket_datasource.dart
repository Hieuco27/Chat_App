import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:chat_app/features/chat/data/models/chat_message_model.dart';

/// Socket Data Source cho Chat — giao tiếp realtime qua Socket.IO
/// Xử lý: kết nối, gửi/nhận tin nhắn realtime, join/leave room
class ChatSocketDatasource {
  io.Socket? socket;
  //final String serverUrl = 'http://10.0.2.2:3000'; // Đổi IP nếu dùng máy thật
  final String serverUrl =
      'http://localhost:3000'; // Dùng localhost cho iOS Simulator

  void connect({
    required String userId,
    required Function(ChatMessageModel) onMessageReceived,
  }) {
    socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({'userId': userId})
          .build(),
    );

    socket?.connect();

    socket?.onConnect((_) {
      debugPrint('✅ Connected to Socket Server');
    });

    // Lắng nghe tin nhắn từ Server
    socket?.on('receive_message', (data) {
      final message = ChatMessageModel.fromJson(data);
      onMessageReceived(message);
    });

    socket?.onDisconnect((_) => debugPrint('❌ Disconnected'));
  }

  // Tham gia vào một phòng 1-1
  void joinRoom(String roomId) {
    socket?.emit('join_room', roomId);
  }

  // Gửi tin nhắn
  void sendMessage(ChatMessageModel message) {
    socket?.emit('send_message', message.toJson());
  }

  // Rời phòng chat
  void leaveRoom(String roomId) {
    socket?.emit('leave_room', roomId);
  }

  void dispose() {
    socket?.disconnect();
    socket?.dispose();
  }
}
