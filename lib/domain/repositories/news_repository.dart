// lib/domain/repositories/news_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/article.dart';

abstract class NewsRepository {
  /// Fetches the top headlines feed with pagination.
  Future<Either<Failure, List<Article>>> getTopHeadlines({
    required int page,
    String? category,
  });

  /// Searches articles by query with pagination.
  Future<Either<Failure, List<Article>>> searchArticles({
    required String query,
    required int page,
  });

  // --- Bookmark operations (synchronous-friendly) ---

  /// Returns all bookmarked articles.
  List<Article> getBookmarks();

  /// Saves an article to bookmarks.
  Future<Either<Failure, Unit>> addBookmark(Article article);

  /// Removes an article from bookmarks.
  Future<Either<Failure, Unit>> removeBookmark(String articleId);

  /// Returns true if an article is bookmarked.
  bool isBookmarked(String articleId);
}
