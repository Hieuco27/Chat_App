import 'package:chat_app/features/chat/domain/repository/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_user_event.dart';
import 'search_user_state.dart';

class SearchUserBloc extends Bloc<SearchUserEvent, SearchUserState> {
  final ChatRepository _chatRepository;

  SearchUserBloc({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const SearchUserState()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchUserState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(const SearchUserState());
      return;
    }

    emit(state.copyWith(status: SearchUserStatus.loading));

    try {
      final users = await _chatRepository.searchUsers(event.query);
      emit(state.copyWith(status: SearchUserStatus.success, users: users));
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchUserStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
