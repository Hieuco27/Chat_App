import 'package:chat_app/features/chat/domain/entities/chat_room.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  final ChatRoomEntity room;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatListScreen({
    super.key,
    required this.room,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Lấy thông tin đối phương (Lọc bỏ ID của mình trong participants)
    final String otherUserId = room.participants.firstWhere(
      (id) => id != currentUserId,
    );
    final otherUserProfile = room.userProfiles[otherUserId];

    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(
              otherUserProfile?.photoUrl ?? 'https://via.placeholder.com/150',
            ),
          ),
          // Nếu bạn có logic online/offline thì thêm chấm xanh ở đây
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        otherUserProfile?.displayName ?? "Người dùng",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        room.lastMessageContent,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey[600],
          // Nếu bạn muốn in đậm khi có tin nhắn chưa đọc:
          // fontWeight: room.isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(room.updatedAt),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 4),
          // Hiển thị số tin nhắn chưa đọc (nếu có)
          // Container(
          //   padding: const EdgeInsets.all(6),
          //   decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          //   child: const Text("1", style: TextStyle(color: Colors.white, fontSize: 10)),
          // )
        ],
      ),
    );
  }

  // Hàm helper để định dạng thời gian nhanh (Sau này bạn nên dùng package intl)
  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
