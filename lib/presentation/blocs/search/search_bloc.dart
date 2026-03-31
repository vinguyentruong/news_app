// lib/presentation/blocs/search/search_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/usecases/search_articles.dart';

part 'search_event.dart';
part 'search_state.dart';

/// Custom event transformer that debounces [SearchQueryChanged] events
/// to prevent hammering the API on every keystroke.
EventTransformer<SearchQueryChanged> _debounceTransformer() {
  return (events, mapper) => events
      .debounceTime(AppConstants.searchDebounce)
      .distinct()
      .switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchArticles searchArticles;

  SearchBloc({required this.searchArticles}) : super(const SearchState()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: _debounceTransformer(),
    );
    on<SearchNextPageFetched>(_onNextPageFetched);
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }

    emit(SearchState(
      status: SearchStatus.loading,
      query: query,
    ));

    await _fetchPage(emit, query: query, page: 1, replace: true);
  }

  Future<void> _onNextPageFetched(
    SearchNextPageFetched event,
    Emitter<SearchState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.status == SearchStatus.loadingMore ||
        state.query.isEmpty) return;

    emit(state.copyWith(status: SearchStatus.loadingMore));
    await _fetchPage(
      emit,
      query: state.query,
      page: state.currentPage + 1,
      replace: false,
    );
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(const SearchState());
  }

  Future<void> _fetchPage(
    Emitter<SearchState> emit, {
    required String query,
    required int page,
    required bool replace,
  }) async {
    final result = await searchArticles(
      SearchParams(query: query, page: page),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: SearchStatus.failure,
        errorMessage: failure.message,
      )),
      (articles) {
        final updated = replace ? articles : [...state.articles, ...articles];
        emit(state.copyWith(
          status: SearchStatus.success,
          articles: updated,
          currentPage: page,
          hasReachedMax: articles.length < AppConstants.pageSize,
        ));
      },
    );
  }
}
