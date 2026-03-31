// lib/data/repositories/news_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_local_datasource.dart';
import '../datasources/news_remote_datasource.dart';
import '../models/article_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // ─── Feed ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Article>>> getTopHeadlines({
    required int page,
    String? category,
  }) async {
    final cacheKey = 'headlines_${category ?? 'general'}_page_$page';

    // Return cache if valid (page 1 only, to keep UX fresh)
    if (page == 1 && localDataSource.isCacheValid(cacheKey)) {
      return _getCachedArticles(cacheKey);
    }

    if (!await networkInfo.isConnected) {
      // Offline: serve stale cache if available
      return _getCachedArticles(cacheKey);
    }

    return _fetchAndCache(
      cacheKey: cacheKey,
      fetch: () => remoteDataSource.getTopHeadlines(page: page, category: category),
    );
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Article>>> searchArticles({
    required String query,
    required int page,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    final cacheKey = 'search_${query}_page_$page';

    if (localDataSource.isCacheValid(cacheKey)) {
      return _getCachedArticles(cacheKey);
    }

    return _fetchAndCache(
      cacheKey: cacheKey,
      fetch: () => remoteDataSource.searchArticles(query: query, page: page),
    );
  }

  // ─── Bookmarks ────────────────────────────────────────────────────────────

  @override
  List<Article> getBookmarks() {
    return localDataSource.getBookmarks().map((m) => m.toEntity()).toList();
  }

  @override
  Future<Either<Failure, Unit>> addBookmark(Article article) async {
    try {
      await localDataSource.addBookmark(ArticleModel.fromEntity(article));
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Failed to save bookmark'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeBookmark(String articleId) async {
    try {
      await localDataSource.removeBookmark(articleId);
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Failed to remove bookmark'));
    }
  }

  @override
  bool isBookmarked(String articleId) => localDataSource.isBookmarked(articleId);

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Future<Either<Failure, List<Article>>> _fetchAndCache({
    required String cacheKey,
    required Future<List<ArticleModel>> Function() fetch,
  }) async {
    try {
      final models = await fetch();
      await localDataSource.cacheArticles(cacheKey, models);
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException {
      return const Left(CacheFailure());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  Future<Either<Failure, List<Article>>> _getCachedArticles(String cacheKey) async {
    try {
      final models = await localDataSource.getCachedArticles(cacheKey);
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException {
      return const Left(NetworkFailure(
        'No internet connection and no cached data available.',
      ));
    }
  }
}
