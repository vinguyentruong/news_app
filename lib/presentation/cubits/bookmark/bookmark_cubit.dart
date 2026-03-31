// lib/presentation/cubits/bookmark/bookmark_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/usecases/bookmark_usecases.dart';

part 'bookmark_state.dart';

/// Uses Cubit (not full Bloc) because bookmark state is simple
/// toggle logic with no complex event streams. This demonstrates
/// choosing the right tool for the job.
class BookmarkCubit extends Cubit<BookmarkState> {
  final GetBookmarks getBookmarks;
  final AddBookmark addBookmark;
  final RemoveBookmark removeBookmark;
  final IsBookmarked isBookmarked;

  BookmarkCubit({
    required this.getBookmarks,
    required this.addBookmark,
    required this.removeBookmark,
    required this.isBookmarked,
  }) : super(const BookmarkState()) {
    _loadBookmarks();
  }

  void _loadBookmarks() {
    final bookmarks = getBookmarks();
    emit(state.copyWith(bookmarks: bookmarks));
  }

  Future<void> toggleBookmark(Article article) async {
    final bookmarked = isBookmarked(article.id);
    if (bookmarked) {
      final result = await removeBookmark(article.id);
      result.fold(
        (failure) => emit(state.copyWith(errorMessage: failure.message)),
        (_) {
          final updated = state.bookmarks.where((a) => a.id != article.id).toList();
          emit(state.copyWith(bookmarks: updated, clearError: true));
        },
      );
    } else {
      final result = await addBookmark(article);
      result.fold(
        (failure) => emit(state.copyWith(errorMessage: failure.message)),
        (_) {
          emit(state.copyWith(
            bookmarks: [article, ...state.bookmarks],
            clearError: true,
          ));
        },
      );
    }
  }

  bool checkIsBookmarked(String articleId) => isBookmarked(articleId);
}
