import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeaderChatScreen extends StatelessWidget {
  final String name;
  final String avatar;
  final bool isOnline;
  const HeaderChatScreen({
    super.key,
    required this.name,
    required this.avatar,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          CircleAvatar(
            radius: 18.r,
            backgroundImage: avatar.isNotEmpty == true
                ? CachedNetworkImageProvider(avatar)
                : null,
            child: avatar.isEmpty != false
                ? const Icon(Icons.person, size: 20)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16)),
                if (isOnline == true)
                  const Text(
                    "Đang hoạt động",
                    style: TextStyle(fontSize: 11, color: Colors.green),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              // TODO: Implement video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // TODO: Implement voice call
            },
          ),
        ],
      ),
    );
  }
}
