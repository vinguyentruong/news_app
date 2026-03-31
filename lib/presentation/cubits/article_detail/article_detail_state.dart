// lib/presentation/cubits/article_detail/article_detail_state.dart
part of 'article_detail_cubit.dart';

class ArticleDetailState extends Equatable {
  final Article article;
  final double loadingProgress;
  final bool isWebViewLoaded;
  final String? error;

  const ArticleDetailState({
    required this.article,
    this.loadingProgress = 0.0,
    this.isWebViewLoaded = false,
    this.error,
  });

  ArticleDetailState copyWith({
    double? loadingProgress,
    bool? isWebViewLoaded,
    String? error,
  }) {
    return ArticleDetailState(
      article: article,
      loadingProgress: loadingProgress ?? this.loadingProgress,
      isWebViewLoaded: isWebViewLoaded ?? this.isWebViewLoaded,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [article, loadingProgress, isWebViewLoaded, error];
}
