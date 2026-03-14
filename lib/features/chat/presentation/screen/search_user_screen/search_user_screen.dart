import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/chat/domain/entities/chat_user.dart';
import 'package:chat_app/features/chat/domain/repository/chat_repository.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat/chat_event.dart';
import 'package:chat_app/features/chat/presentation/bloc/search_user/search_user_bloc.dart';
import 'package:chat_app/features/chat/presentation/bloc/search_user/search_user_event.dart';
import 'package:chat_app/features/chat/presentation/bloc/search_user/search_user_state.dart';
import 'package:chat_app/features/chat/presentation/screen/chat_screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchUserScreen extends StatelessWidget {
  const SearchUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatRepository = context.read<ChatRepository>();
    final currentUserId = context.read<AuthBloc>().state.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm người dùng...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            context.read<SearchUserBloc>().add(SearchQueryChanged(query));
          },
        ),
      ),
      body: BlocBuilder<SearchUserBloc, SearchUserState>(
        builder: (context, state) {
          if (state.status == SearchUserStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == SearchUserStatus.error) {
            return Center(child: Text('Lỗi: ${state.errorMessage}'));
          }

          if (state.users.isEmpty && state.status == SearchUserStatus.success) {
            return const Center(child: Text('Không tìm thấy người dùng nào.'));
          }

          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];

              // Không hiện chính mình
              if (user.uid == currentUserId) return const SizedBox.shrink();

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: user.photoUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(user.displayName),
                subtitle: Text(user.email),
                onTap: () async {
                  // Logic bắt đầu cuộc trò chuyện
                  _startChat(context, currentUserId, user, chatRepository);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _startChat(
    BuildContext context,
    String currentUserId,
    ChatUserEntity otherUser,
    ChatRepository repository,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Tạo hoặc lấy roomId (Vì đơn giản, ta sẽ tạo room chứa cả 2 ID)
      // Lưu ý: Để tối ưu, nên kiểm tra xem room đã tồn tại chưa trước khi gọi createRoom.
      // Ở đây tôi gọi createRoom xử lý (hàm này trong datasource của bạn đang là dùng add())
      final List<String> participants = [currentUserId, otherUser.uid];
      participants
          .sort(); // Sắp xếp để ID phòng luôn nhất quán nếu dùng custom ID

      // Tạo phòng chat
      await repository.createRoom(participants);

      // Đóng loading
      if (context.mounted) Navigator.pop(context);

      // 2. Chuyển tới màn hình Chat
      if (context.mounted) {
        // Bạn cần một cơ chế để lấy được roomId vừa tạo.
        // Trong trường hợp này, danh sách phòng chat ở màn hình chính sẽ tự động update qua Stream.
        // Ta có thể quay lại màn hình chính và người dùng sẽ thấy phòng chat mới hiện lên.
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã bắt đầu cuộc hội thoại!')),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // close loading
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }
}
