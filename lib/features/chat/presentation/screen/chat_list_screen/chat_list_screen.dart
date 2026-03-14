import 'package:chat_app/features/chat/presentation/screen/chat_screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_event.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/chat_list/chat_list_bloc.dart';
import '../../bloc/chat_list/chat_list_event.dart';
import '../../bloc/chat_list/chat_list_state.dart';
import '../../bloc/search_user/search_user_bloc.dart';
import '../search_user_screen/search_user_screen.dart';
import 'package:chat_app/features/chat/domain/repository/chat_repository.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    // Lấy userId từ AuthBloc
    currentUserId = context.read<AuthBloc>().state.user?.uid ?? '';
    // Dispatch event load rooms
    context.read<ChatListBloc>().add(ChatListStarted(userId: currentUserId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tin nhắn"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),

      // BlocBuilder lắng nghe state
      body: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, state) {
          // Loading
          if (state is ChatListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // Error
          if (state is ChatListError) {
            return Center(child: Text(state.errorMessage));
          }

          // Loaded — hiển thị danh sách rooms
          if (state is ChatListLoaded) {
            final rooms = state.rooms;

            if (rooms.isEmpty) {
              return const Center(child: Text("Chưa có cuộc trò chuyện nào"));
            }

            return ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];

                // Lấy thông tin người chat đối diện (filter bỏ ID của tôi)
                final otherUserId = room.participants.firstWhere(
                  (id) => id != currentUserId,
                  orElse: () => room.participants.first,
                );

                final otherUser = room.userProfiles[otherUserId];

                return ListTile(
                  // Avatar
                  leading: CircleAvatar(
                    backgroundImage:
                        (otherUser?.photoUrl != null &&
                            otherUser!.photoUrl.isNotEmpty)
                        ? NetworkImage(otherUser.photoUrl)
                        : const NetworkImage('https://via.placeholder.com/150'),
                  ),
                  // Tên
                  title: Text(
                    otherUser?.displayName ?? "Người dùng",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Tin nhắn cuối
                  subtitle: Text(
                    room.lastMessageContent,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Thời gian
                  trailing: Text(
                    "${room.updatedAt.hour}:${room.updatedAt.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => ChatBloc(
                            context.read<ChatListBloc>().chatRepository,
                          ),
                          child: ChatScreen(
                            userId: currentUserId,
                            roomId: room.id,
                            otherUser: otherUser,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox(); // Trạng thái initial
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mở màn hình tìm kiếm người dùng mới
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (innerContext) => BlocProvider(
                create: (context) => SearchUserBloc(
                  chatRepository: context.read<ChatRepository>(),
                ),
                child: const SearchUserScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}
