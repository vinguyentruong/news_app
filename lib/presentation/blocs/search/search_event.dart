// lib/presentation/blocs/search/search_event.dart
part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class SearchNextPageFetched extends SearchEvent {
  const SearchNextPageFetched();
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}
