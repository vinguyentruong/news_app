// lib/presentation/blocs/news_feed/news_feed_state.dart
part of 'news_feed_bloc.dart';

enum NewsFeedStatus { initial, loading, success, failure, loadingMore }

class NewsFeedState extends Equatable {
  final NewsFeedStatus status;
  final List<Article> articles;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final String? selectedCategory;

  const NewsFeedState({
    this.status = NewsFeedStatus.initial,
    this.articles = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.selectedCategory,
  });

  NewsFeedState copyWith({
    NewsFeedStatus? status,
    List<Article>? articles,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    String? selectedCategory,
    bool clearError = false,
  }) {
    return NewsFeedState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [
        status,
        articles,
        errorMessage,
        hasReachedMax,
        currentPage,
        selectedCategory,
      ];
}
