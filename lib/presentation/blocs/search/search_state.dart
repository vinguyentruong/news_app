// lib/presentation/blocs/search/search_state.dart
part of 'search_bloc.dart';

enum SearchStatus { idle, loading, success, failure, loadingMore }

class SearchState extends Equatable {
  final SearchStatus status;
  final String query;
  final List<Article> articles;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;

  const SearchState({
    this.status = SearchStatus.idle,
    this.query = '',
    this.articles = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  bool get isIdle => status == SearchStatus.idle;
  bool get isLoading => status == SearchStatus.loading;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Article>? articles,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    bool clearError = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      articles: articles ?? this.articles,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        query,
        articles,
        errorMessage,
        hasReachedMax,
        currentPage,
      ];
}
