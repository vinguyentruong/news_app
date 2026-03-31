// lib/presentation/blocs/news_feed/news_feed_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/usecases/get_top_headlines.dart';

part 'news_feed_event.dart';
part 'news_feed_state.dart';

class NewsFeedBloc extends Bloc<NewsFeedEvent, NewsFeedState> {
  final GetTopHeadlines getTopHeadlines;

  NewsFeedBloc({required this.getTopHeadlines}) : super(const NewsFeedState()) {
    on<NewsFeedStarted>(_onStarted);
    on<NewsFeedRefreshed>(_onRefreshed);
    on<NewsFeedNextPageFetched>(_onNextPageFetched);
    on<NewsFeedCategoryChanged>(_onCategoryChanged);
  }

  Future<void> _onStarted(
    NewsFeedStarted event,
    Emitter<NewsFeedState> emit,
  ) async {
    if (state.status == NewsFeedStatus.success) return;
    await _fetchPage(emit, page: 1, replace: true);
  }

  Future<void> _onRefreshed(
    NewsFeedRefreshed event,
    Emitter<NewsFeedState> emit,
  ) async {
    await _fetchPage(emit, page: 1, replace: true);
  }

  Future<void> _onNextPageFetched(
    NewsFeedNextPageFetched event,
    Emitter<NewsFeedState> emit,
  ) async {
    if (state.hasReachedMax || state.status == NewsFeedStatus.loadingMore) return;
    await _fetchPage(emit, page: state.currentPage + 1, replace: false);
  }

  Future<void> _onCategoryChanged(
    NewsFeedCategoryChanged event,
    Emitter<NewsFeedState> emit,
  ) async {
    emit(state.copyWith(
      selectedCategory: event.category,
      articles: [],
      currentPage: 1,
      hasReachedMax: false,
      status: NewsFeedStatus.loading,
    ));
    await _fetchPage(
      emit,
      page: 1,
      replace: true,
      category: event.category,
    );
  }

  Future<void> _fetchPage(
    Emitter<NewsFeedState> emit, {
    required int page,
    required bool replace,
    String? category,
  }) async {
    emit(state.copyWith(
      status: replace ? NewsFeedStatus.loading : NewsFeedStatus.loadingMore,
      clearError: true,
    ));

    final result = await getTopHeadlines(
      HeadlinesParams(
        page: page,
        category: category ?? state.selectedCategory,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: NewsFeedStatus.failure,
        errorMessage: failure.message,
      )),
      (articles) {
        final updated = replace ? articles : [...state.articles, ...articles];
        emit(state.copyWith(
          status: NewsFeedStatus.success,
          articles: updated,
          currentPage: page,
          hasReachedMax: articles.length < AppConstants.pageSize,
        ));
      },
    );
  }
}
