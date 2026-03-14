import 'dart:io';
import 'package:chat_app/features/chat/domain/entities/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/chat/chat_event.dart';
import '../../bloc/chat/chat_state.dart';
import 'package:chat_app/features/chat/domain/entities/chat_user.dart';
import 'package:chat_app/widget/dismiss_keyboard_widget.dart';
import 'package:chat_app/features/chat/presentation/screen/chat_screen/widgets/header_chat_screen.dart';
import 'package:chat_app/features/chat/presentation/screen/chat_screen/widgets/chat_input_field.dart';
import 'package:chat_app/features/chat/presentation/screen/chat_screen/widgets/emoji_picker_widget.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String roomId;
  final ChatUserEntity? otherUser;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.roomId,
    this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isShowEmojiPicker = false;
  String? _selectedMessageId;

  @override
  void initState() {
    super.initState();
    // Dispatch event khi mở màn hình
    context.read<ChatBloc>().add(
      ChatStart(userId: widget.userId, roomId: widget.roomId),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _isShowEmojiPicker) {
        setState(() {
          _isShowEmojiPicker = false;
        });
      }
    });
  }

  void _toggleEmojiPicker() {
    if (!_isShowEmojiPicker) {
      // Đang tắt => Bật lên, đồng thời ẩn bàn phím
      FocusScope.of(context).unfocus();
    } else {
      // Đang bật => Tắt đi, đồng thời bật bàn phím
      _focusNode.requestFocus();
    }
    setState(() {
      _isShowEmojiPicker = !_isShowEmojiPicker;
    });
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    final int hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final String period = time.hour >= 12 ? "PM" : "AM";
    final String timeString =
        "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";

    if (difference.inDays == 0 && now.day == time.day) {
      // Hôm nay
      return timeString;
    } else if (difference.inDays == 1 ||
        (difference.inDays == 0 && now.day != time.day)) {
      // Hôm qua
      return "Hôm qua lúc $timeString";
    } else {
      // Các ngày khác
      return "$timeString - ${time.day}/${time.month}/${time.year}";
    }
  }

  void _send() {
    if (_controller.text.isEmpty) return;

    final newMessage = ChatMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.userId,
      content: _controller.text,
      createAt: DateTime.now(),
      type: MessageType.text,
      roomId: widget.roomId,
      isRead: false,
    );

    // Dispatch event → Bloc xử lý gửi tin nhắn
    context.read<ChatBloc>().add(ChatSendMessage(message: newMessage));
    _controller.clear();
    _scrollToBottom();
  }

  void _sendAudio(String path) {
    final newMessage = ChatMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.userId,
      content: path, // Local path temporary, wait until upload completes
      createAt: DateTime.now(),
      type: MessageType.voice,
      roomId: widget.roomId,
      isRead: false,
    );

    context.read<ChatBloc>().add(
      ChatSendMediaMessage(
        message: newMessage,
        file: File(path),
        pathFolder: 'chat_audios',
      ),
    );
    _scrollToBottom();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickMedia(ImageSource source, MessageType type) async {
    final picker = ImagePicker();
    XFile? file;
    if (type == MessageType.image) {
      file = await picker.pickImage(source: source);
    } else if (type == MessageType.video) {
      file = await picker.pickVideo(source: source);
    }

    if (file != null) {
      final newMessage = ChatMessageEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: widget.userId,
        content: file.path, // Tạm thời hiện local path
        createAt: DateTime.now(),
        type: type,
        roomId: widget.roomId,
        isRead: false,
      );

      String folder = type == MessageType.image ? 'chat_images' : 'chat_videos';

      context.read<ChatBloc>().add(
        ChatSendMediaMessage(
          message: newMessage,
          file: File(file.path),
          pathFolder: folder,
        ),
      );
      _scrollToBottom();
    }
  }

  void _openAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.camera, MessageType.image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.green),
                title: const Text('Chọn ảnh từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.gallery, MessageType.image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.red),
                title: const Text('Quay video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.camera, MessageType.video);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library, color: Colors.orange),
                title: const Text('Chọn video từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.gallery, MessageType.video);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BlocBuilder
      body: DismissKeyboardWidget(
        onDismiss: () {
          if (_isShowEmojiPicker) {
            setState(() {
              _isShowEmojiPicker = false;
            });
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              HeaderChatScreen(
                name: widget.otherUser?.displayName ?? "Chat",
                avatar: widget.otherUser?.photoUrl ?? "",
                isOnline: widget.otherUser?.isOnline ?? false,
              ),
              const Divider(height: 1),
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
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
                            controller: _scrollController,
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final msg = state.messages[index];
                              bool isMe = msg.senderId == widget.userId;
                              return Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (_selectedMessageId == msg.id)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _formatMessageTime(msg.createAt),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_selectedMessageId == msg.id) {
                                          _selectedMessageId = null;
                                        } else {
                                          _selectedMessageId = msg.id;
                                        }
                                      });
                                    },
                                    child: Align(
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
                                          color: isMe
                                              ? Colors.blue
                                              : Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: msg.type == MessageType.voice
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.mic,
                                                    color: isMe
                                                        ? Colors.white
                                                        : Colors.black,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "Tin nhắn thoại",
                                                    style: TextStyle(
                                                      color: isMe
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : msg.type == MessageType.image
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child:
                                                    msg.content.startsWith(
                                                      'http',
                                                    )
                                                    ? Image.network(
                                                        msg.content,
                                                        width: 200,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.file(
                                                        File(msg.content),
                                                        width: 200,
                                                        fit: BoxFit.cover,
                                                      ),
                                              )
                                            : msg.type == MessageType.video
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.video_library,
                                                    color: isMe
                                                        ? Colors.white
                                                        : Colors.black,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "Video",
                                                    style: TextStyle(
                                                      color: isMe
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                msg.content,
                                                style: TextStyle(
                                                  color: isMe
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  if (_selectedMessageId == msg.id && isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 12,
                                        top: 2,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        msg.isRead ? "Đã xem" : "Đã gửi",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                        // Input area
                        ChatInputField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onSend: _send,
                          onEmojiTap: _toggleEmojiPicker,
                          onAttachmentTap: _openAttachmentMenu,
                          onSendAudio: _sendAudio,
                        ),
                        if (_isShowEmojiPicker)
                          EmojiPickerWidget(textEditingController: _controller),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
