import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback onSend;
  final VoidCallback onEmojiTap;
  final VoidCallback onAttachmentTap;
  final Function(String path) onSendAudio;

  const ChatInputField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.onSend,
    required this.onEmojiTap,
    required this.onAttachmentTap,
    required this.onSendAudio,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _isTyping = false;
  late final RecorderController recorderController;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    recorderController = RecorderController();

    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isTyping = widget.controller.text.isNotEmpty;
    });
  }

  void _startRecording() async {
    final hasPermission = await recorderController.checkPermission();
    if (hasPermission) {
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await recorderController.record(path: path);
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _stopRecording() async {
    final path = await recorderController.stop();
    setState(() {
      _isRecording = false;
    });
    if (path != null) {
      // Gửi đường dẫn âm thanh này qua bloc để upload
      // Tạm in ra để demo
      print('Ghi âm thành công: $path');
      widget.onSendAudio(path);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
              onPressed: widget.onAttachmentTap, // Mở menu gửi ảnh, location
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: widget.onEmojiTap,
                    ),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        maxLines: 5,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          hintText: "Nhập tin nhắn...",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: _isTyping ? Colors.blue : Colors.blue,
              child: GestureDetector(
                onTap: _isTyping ? widget.onSend : null,
                onLongPress: !_isTyping
                    ? () {
                        _startRecording();
                        print("Bắt đầu ghi âm");
                      }
                    : null,
                onLongPressUp: !_isTyping
                    ? () {
                        _stopRecording();
                        print("Dừng ghi âm và gửi");
                      }
                    : null,
                child: Container(
                  color: Colors.transparent, // required for gesture detector
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _isTyping ? Icons.send : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
