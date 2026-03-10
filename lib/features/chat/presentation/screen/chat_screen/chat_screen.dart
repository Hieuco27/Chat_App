import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/features/chat/data/models/chat_message_model.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/chat/chat_event.dart';
import '../../bloc/chat/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String roomId;

  const ChatScreen({super.key, required this.userId, required this.roomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Dispatch event khi mở màn hình
    context.read<ChatBloc>().add(
      ChatStart(userId: widget.userId, roomId: widget.roomId),
    );
  }

  void _send() {
    if (_controller.text.isEmpty) return;

    final newMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.userId,
      content: _controller.text,
      createAt: DateTime.now(),
      roomId: widget.roomId,
      isRead: false,
    );

    // Dispatch event → Bloc xử lý gửi tin nhắn
    context.read<ChatBloc>().add(ChatSendMessage(message: newMessage));
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat - ${widget.roomId}")),
      // BlocBuilder lắng nghe state → tự rebuild UI
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          // Xử lý trạng thái loading
          if (state.status == ChatStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          // Xử lý trạng thái error
          if (state.status == ChatStatus.error) {
            return Center(child: Text(state.errorMessage));
          }
          // Trạng thái loaded → hiển thị messages
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    bool isMe = msg.senderId == widget.userId;
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg.content,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Input area
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Nhập tin nhắn...",
                        ),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.send), onPressed: _send),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
