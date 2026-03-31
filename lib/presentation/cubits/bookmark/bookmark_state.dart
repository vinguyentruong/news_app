// lib/presentation/cubits/bookmark/bookmark_state.dart
part of 'bookmark_cubit.dart';

class BookmarkState extends Equatable {
  final List<Article> bookmarks;
  final String? errorMessage;

  const BookmarkState({
    this.bookmarks = const [],
    this.errorMessage,
  });

  BookmarkState copyWith({
    List<Article>? bookmarks,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [bookmarks, errorMessage];
}
