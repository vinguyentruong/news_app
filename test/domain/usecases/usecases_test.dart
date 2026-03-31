// test/domain/usecases/usecases_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/error/failures.dart' show ServerFailure;
import 'package:news_app/domain/entities/article.dart';
import 'package:news_app/domain/repositories/news_repository.dart';
import 'package:news_app/domain/usecases/bookmark_usecases.dart';
import 'package:news_app/domain/usecases/get_top_headlines.dart';
import 'package:news_app/domain/usecases/search_articles.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

void main() {
  late MockNewsRepository mockRepo;

  final tArticle = Article(
    id: '1',
    title: 'Test Article',
    url: 'https://example.com',
    sourceName: 'Test',
    publishedAt: DateTime(2024),
  );

  setUp(() {
    mockRepo = MockNewsRepository();
  });

  // ─── GetTopHeadlines ──────────────────────────────────────────────────────

  group('GetTopHeadlines', () {
    late GetTopHeadlines useCase;
    setUp(() => useCase = GetTopHeadlines(mockRepo));

    test('calls repository with correct params', () async {
      when(
        () => mockRepo.getTopHeadlines(page: 1, category: 'tech'),
      ).thenAnswer((_) async => Right([tArticle]));

      final result = await useCase(
        const HeadlinesParams(page: 1, category: 'tech'),
      );

      expect(result, isA<Right>());
      verify(
        () => mockRepo.getTopHeadlines(page: 1, category: 'tech'),
      ).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns failure from repository unchanged', () async {
      when(
        () => mockRepo.getTopHeadlines(page: 1),
      ).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase(const HeadlinesParams(page: 1));

      expect(result, isA<Left>());
    });
  });

  // ─── SearchArticles ───────────────────────────────────────────────────────

  group('SearchArticles', () {
    late SearchArticles useCase;
    setUp(() => useCase = SearchArticles(mockRepo));

    test('calls repository with correct query and page', () async {
      when(
        () => mockRepo.searchArticles(query: 'flutter', page: 2),
      ).thenAnswer((_) async => Right([tArticle]));

      final result = await useCase(
        const SearchParams(query: 'flutter', page: 2),
      );

      expect(result, isA<Right>());
      verify(
        () => mockRepo.searchArticles(query: 'flutter', page: 2),
      ).called(1);
    });
  });

  // ─── Bookmark use cases ───────────────────────────────────────────────────

  group('GetBookmarks', () {
    test('returns list from repository', () {
      when(() => mockRepo.getBookmarks()).thenReturn([tArticle]);
      final result = GetBookmarks(mockRepo)();
      expect(result, [tArticle]);
    });
  });

  group('AddBookmark', () {
    test('calls addBookmark on repository', () async {
      when(
        () => mockRepo.addBookmark(tArticle),
      ).thenAnswer((_) async => const Right(unit));
      final result = await AddBookmark(mockRepo)(tArticle);
      expect(result, const Right(unit));
      verify(() => mockRepo.addBookmark(tArticle)).called(1);
    });
  });

  group('RemoveBookmark', () {
    test('calls removeBookmark on repository', () async {
      when(
        () => mockRepo.removeBookmark('1'),
      ).thenAnswer((_) async => const Right(unit));
      final result = await RemoveBookmark(mockRepo)('1');
      expect(result, const Right(unit));
      verify(() => mockRepo.removeBookmark('1')).called(1);
    });
  });

  group('IsBookmarked', () {
    test('returns true when article is bookmarked', () {
      when(() => mockRepo.isBookmarked('1')).thenReturn(true);
      expect(IsBookmarked(mockRepo)('1'), isTrue);
    });

    test('returns false when article is not bookmarked', () {
      when(() => mockRepo.isBookmarked('99')).thenReturn(false);
      expect(IsBookmarked(mockRepo)('99'), isFalse);
    });
  });
}
