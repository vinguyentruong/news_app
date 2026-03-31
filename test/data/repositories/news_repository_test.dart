// test/data/repositories/news_repository_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/error/exceptions.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/core/network/network_info.dart';
import 'package:news_app/data/datasources/news_local_datasource.dart';
import 'package:news_app/data/datasources/news_remote_datasource.dart';
import 'package:news_app/data/models/article_model.dart';
import 'package:news_app/data/repositories/news_repository_impl.dart';
import 'package:news_app/domain/entities/article.dart';

class MockRemoteDataSource extends Mock implements NewsRemoteDataSource {}

class MockLocalDataSource extends Mock implements NewsLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NewsRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;
  late MockNetworkInfo mockNetwork;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    mockNetwork = MockNetworkInfo();
    repository = NewsRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
      networkInfo: mockNetwork,
    );
  });

  final tArticleModel = ArticleModel(
    id: '123',
    title: 'Test Article',
    url: 'https://example.com/article',
    sourceName: 'Test Source',
    publishedAt: DateTime(2024, 1, 15),
    description: 'Test description',
    author: 'Test Author',
  );

  final tArticle = tArticleModel.toEntity();

  // ─── getTopHeadlines ──────────────────────────────────────────────────────

  group('getTopHeadlines', () {
    const cacheKey = 'headlines_general_page_1';

    test(
        'returns remote data and caches when online and cache invalid',
        () async {
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(() => mockLocal.isCacheValid(cacheKey)).thenReturn(false);
      when(() => mockRemote.getTopHeadlines(page: 1))
          .thenAnswer((_) async => [tArticleModel]);
      when(() => mockLocal.cacheArticles(any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.getTopHeadlines(page: 1);

      expect(result, isA<Right<Failure, List<Article>>>());
      result.fold(
        (_) => fail('Expected Right'),
        (articles) => expect(articles.first.title, tArticle.title),
      );
      verify(() => mockLocal.cacheArticles(cacheKey, [tArticleModel])).called(1);
    });

    test('returns valid cache without network call when cache is fresh',
        () async {
      when(() => mockLocal.isCacheValid(cacheKey)).thenReturn(true);
      when(() => mockLocal.getCachedArticles(cacheKey))
          .thenAnswer((_) async => [tArticleModel]);

      final result = await repository.getTopHeadlines(page: 1);

      expect(result, isA<Right<Failure, List<Article>>>());
      verifyNever(
          () => mockRemote.getTopHeadlines(page: any(named: 'page')));
    });

    test('returns stale cache when offline and cache exists', () async {
      when(() => mockNetwork.isConnected).thenAnswer((_) async => false);
      when(() => mockLocal.isCacheValid(cacheKey)).thenReturn(false);
      when(() => mockLocal.getCachedArticles(cacheKey))
          .thenAnswer((_) async => [tArticleModel]);

      final result = await repository.getTopHeadlines(page: 1);

      expect(result, isA<Right<Failure, List<Article>>>());
    });

    test('returns NetworkFailure when offline and no cache', () async {
      when(() => mockNetwork.isConnected).thenAnswer((_) async => false);
      when(() => mockLocal.isCacheValid(cacheKey)).thenReturn(false);
      when(() => mockLocal.getCachedArticles(cacheKey))
          .thenThrow(const CacheException());

      final result = await repository.getTopHeadlines(page: 1);

      expect(result, isA<Left<Failure, List<Article>>>());
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on server exception', () async {
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(() => mockLocal.isCacheValid(cacheKey)).thenReturn(false);
      when(() => mockRemote.getTopHeadlines(page: 1))
          .thenThrow(const ServerException(message: 'Internal server error'));

      final result = await repository.getTopHeadlines(page: 1);

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Internal server error');
        },
        (_) => fail('Expected Left'),
      );
    });

    test('returns UnauthorizedFailure on 401', () async {
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(() => mockLocal.isCacheValid(cacheKey)).thenReturn(false);
      when(() => mockRemote.getTopHeadlines(page: 1))
          .thenThrow(const UnauthorizedException());

      final result = await repository.getTopHeadlines(page: 1);

      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  // ─── searchArticles ───────────────────────────────────────────────────────

  group('searchArticles', () {
    const query = 'flutter';
    const cacheKey = 'search_flutter_page_1';

    test('returns NetworkFailure immediately when offline', () async {
      when(() => mockNetwork.isConnected).thenAnswer((_) async => false);

      final result = await repository.searchArticles(query: query, page: 1);

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
      verifyNever(
          () => mockRemote.searchArticles(query: any(named: 'query'),
              page: any(named: 'page')));
    });

    test('returns remote results and caches them when online', () async {
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(() => mockLocal.isCacheValid(cacheKey)).thenReturn(false);
      when(() => mockRemote.searchArticles(query: query, page: 1))
          .thenAnswer((_) async => [tArticleModel]);
      when(() => mockLocal.cacheArticles(any(), any()))
          .thenAnswer((_) async {});

      final result =
          await repository.searchArticles(query: query, page: 1);

      expect(result, isA<Right<Failure, List<Article>>>());
      verify(() => mockLocal.cacheArticles(cacheKey, [tArticleModel]))
          .called(1);
    });
  });

  // ─── bookmarks ────────────────────────────────────────────────────────────

  group('bookmarks', () {
    test('getBookmarks maps models to entities', () {
      when(() => mockLocal.getBookmarks()).thenReturn([tArticleModel]);

      final result = repository.getBookmarks();

      expect(result.length, 1);
      expect(result.first.title, tArticle.title);
    });

    test('addBookmark returns Right(unit) on success', () async {
      when(() => mockLocal.addBookmark(any())).thenAnswer((_) async {});

      final result = await repository.addBookmark(tArticle);

      expect(result, const Right(unit));
      verify(() => mockLocal.addBookmark(any())).called(1);
    });

    test('addBookmark returns CacheFailure on exception', () async {
      when(() => mockLocal.addBookmark(any()))
          .thenThrow(Exception('Hive error'));

      final result = await repository.addBookmark(tArticle);

      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('removeBookmark returns Right(unit) on success', () async {
      when(() => mockLocal.removeBookmark(any())).thenAnswer((_) async {});

      final result = await repository.removeBookmark('123');

      expect(result, const Right(unit));
    });

    test('isBookmarked delegates to local datasource', () {
      when(() => mockLocal.isBookmarked('123')).thenReturn(true);
      when(() => mockLocal.isBookmarked('456')).thenReturn(false);

      expect(repository.isBookmarked('123'), isTrue);
      expect(repository.isBookmarked('456'), isFalse);
    });
  });
}
