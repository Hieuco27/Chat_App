import 'package:equatable/equatable.dart';

abstract class SearchUserEvent extends Equatable {
  const SearchUserEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchUserEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}
