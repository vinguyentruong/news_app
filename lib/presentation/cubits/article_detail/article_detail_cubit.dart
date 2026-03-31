// lib/presentation/cubits/article_detail/article_detail_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/article.dart';

part 'article_detail_state.dart';

/// Simple Cubit for article detail screen — tracks webview progress
/// and read state. No complex streams needed here.
class ArticleDetailCubit extends Cubit<ArticleDetailState> {
  ArticleDetailCubit(Article article)
      : super(ArticleDetailState(article: article));

  void updateLoadingProgress(double progress) {
    emit(state.copyWith(loadingProgress: progress));
  }

  void setWebViewReady() {
    emit(state.copyWith(isWebViewLoaded: true, loadingProgress: 1.0));
  }

  void setError(String message) {
    emit(state.copyWith(error: message));
  }
}
