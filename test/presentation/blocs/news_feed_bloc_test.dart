// test/presentation/blocs/news_feed_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/domain/entities/article.dart';
import 'package:news_app/domain/usecases/get_top_headlines.dart';
import 'package:news_app/presentation/blocs/news_feed/news_feed_bloc.dart';

class MockGetTopHeadlines extends Mock implements GetTopHeadlines {}

Article _makeArticle(int i) => Article(
      id: '$i',
      title: 'Article $i',
      url: 'https://example.com/$i',
      sourceName: 'Source',
      publishedAt: DateTime(2024, 1, i + 1),
    );

void main() {
  late NewsFeedBloc bloc;
  late MockGetTopHeadlines mockUseCase;

  // 20 articles = full page, 5 = partial (hasReachedMax = true)
  final fullPage = List.generate(20, _makeArticle);
  final partialPage = List.generate(5, _makeArticle);

  setUpAll(() {
    registerFallbackValue(const HeadlinesParams(page: 1));
  });

  setUp(() {
    mockUseCase = MockGetTopHeadlines();
    bloc = NewsFeedBloc(getTopHeadlines: mockUseCase);
  });

  tearDown(() => bloc.close());

  // ─── Initial state ────────────────────────────────────────────────────────

  test('initial state is correct', () {
    expect(bloc.state, const NewsFeedState());
    expect(bloc.state.status, NewsFeedStatus.initial);
    expect(bloc.state.articles, isEmpty);
    expect(bloc.state.hasReachedMax, isFalse);
  });

  // ─── NewsFeedStarted ──────────────────────────────────────────────────────

  blocTest<NewsFeedBloc, NewsFeedState>(
    'NewsFeedStarted emits [loading, success] with articles',
    build: () {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(partialPage));
      return bloc;
    },
    act: (b) => b.add(const NewsFeedStarted()),
    expect: () => [
      const NewsFeedState(status: NewsFeedStatus.loading),
      NewsFeedState(
        status: NewsFeedStatus.success,
        articles: partialPage,
        currentPage: 1,
        hasReachedMax: true, // 5 < pageSize(20)
      ),
    ],
    verify: (_) {
      verify(() => mockUseCase(const HeadlinesParams(page: 1))).called(1);
    },
  );

  blocTest<NewsFeedBloc, NewsFeedState>(
    'NewsFeedStarted does not refetch if status is already success',
    build: () {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(partialPage));
      return NewsFeedBloc(getTopHeadlines: mockUseCase)
        ..emit(NewsFeedState(
          status: NewsFeedStatus.success,
          articles: partialPage,
        ));
    },
    act: (b) => b.add(const NewsFeedStarted()),
    expect: () => <NewsFeedState>[],
    verify: (_) => verifyNever(() => mockUseCase(any())),
  );

  blocTest<NewsFeedBloc, NewsFeedState>(
    'NewsFeedStarted emits [loading, failure] on network error',
    build: () {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => const Left(NetworkFailure()));
      return bloc;
    },
    act: (b) => b.add(const NewsFeedStarted()),
    expect: () => [
      const NewsFeedState(status: NewsFeedStatus.loading),
      const NewsFeedState(
        status: NewsFeedStatus.failure,
        errorMessage: 'No internet connection. Please check your network.',
      ),
    ],
  );

  // ─── NewsFeedRefreshed ────────────────────────────────────────────────────

  blocTest<NewsFeedBloc, NewsFeedState>(
    'NewsFeedRefreshed replaces articles and resets page',
    build: () {
      final firstArticles = List.generate(3, _makeArticle);
      final refreshedArticles = List.generate(3, (i) => _makeArticle(i + 10));
      var callCount = 0;
      when(() => mockUseCase(any())).thenAnswer((_) async {
        callCount++;
        return callCount == 1
            ? Right(firstArticles)
            : Right(refreshedArticles);
      });
      return bloc;
    },
    act: (b) async {
      b.add(const NewsFeedStarted());
      await Future.delayed(Duration.zero);
      b.add(const NewsFeedRefreshed());
    },
    skip: 2, // skip initial load states
    expect: () => [
      const NewsFeedState(status: NewsFeedStatus.loading),
      predicate<NewsFeedState>((s) =>
          s.status == NewsFeedStatus.success &&
          s.currentPage == 1 &&
          s.articles.first.id == '10'),
    ],
  );

  // ─── NewsFeedNextPageFetched ───────────────────────────────────────────────

  blocTest<NewsFeedBloc, NewsFeedState>(
    'NewsFeedNextPageFetched appends articles and increments page',
    build: () {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(fullPage));
      return bloc;
    },
    seed: () => NewsFeedState(
      status: NewsFeedStatus.success,
      articles: fullPage,
      currentPage: 1,
      hasReachedMax: false,
    ),
    act: (b) => b.add(const NewsFeedNextPageFetched()),
    expect: () => [
      isA<NewsFeedState>()
          .having((s) => s.status, 'status', NewsFeedStatus.loadingMore),
      isA<NewsFeedState>()
          .having((s) => s.articles.length, 'articles count', 40)
          .having((s) => s.currentPage, 'page', 2)
          .having((s) => s.hasReachedMax, 'hasReachedMax', false),
    ],
    verify: (_) {
      verify(() => mockUseCase(const HeadlinesParams(page: 2))).called(1);
    },
  );

  blocTest<NewsFeedBloc, NewsFeedState>(
    'NewsFeedNextPageFetched sets hasReachedMax when partial page returned',
    build: () {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(partialPage));
      return bloc;
    },
    seed: () => NewsFeedState(
      status: NewsFeedStatus.success,
      articles: fullPage,
      currentPage: 1,
      hasReachedMax: false,
    ),
    act: (b) => b.add(const NewsFeedNextPageFetched()),
    expect: () => [
      isA<NewsFeedState>()
          .having((s) => s.status, 'status', NewsFeedStatus.loadingMore),
      isA<NewsFeedState>()
          .having((s) => s.hasReachedMax, 'hasReachedMax', true),
    ],
  );

  blocTest<NewsFeedBloc, NewsFeedState>(
    'NewsFeedNextPageFetched is ignored when hasReachedMax is true',
    build: () => bloc,
    seed: () => NewsFeedState(
      status: NewsFeedStatus.success,
      articles: partialPage,
      currentPage: 1,
      hasReachedMax: true,
    ),
    act: (b) => b.add(const NewsFeedNextPageFetched()),
    expect: () => <NewsFeedState>[],
    verify: (_) => verifyNever(() => mockUseCase(any())),
  );

  blocTest<NewsFeedBloc, NewsFeedState>(
    'NewsFeedNextPageFetched is ignored when already loading more',
    build: () => bloc,
    seed: () => NewsFeedState(
      status: NewsFeedStatus.loadingMore,
      articles: fullPage,
      currentPage: 1,
    ),
    act: (b) => b.add(const NewsFeedNextPageFetched()),
    expect: () => <NewsFeedState>[],
    verify: (_) => verifyNever(() => mockUseCase(any())),
  );

  // ─── NewsFeedCategoryChanged ───────────────────────────────────────────────

  blocTest<NewsFeedBloc, NewsFeedState>(
    'NewsFeedCategoryChanged resets state and fetches for new category',
    build: () {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(partialPage));
      return bloc;
    },
    seed: () => NewsFeedState(
      status: NewsFeedStatus.success,
      articles: fullPage,
      currentPage: 2,
      selectedCategory: null,
    ),
    act: (b) => b.add(const NewsFeedCategoryChanged('technology')),
    expect: () => [
      const NewsFeedState(
        status: NewsFeedStatus.loading,
        articles: [],
        currentPage: 1,
        selectedCategory: 'technology',
      ),
      NewsFeedState(
        status: NewsFeedStatus.success,
        articles: partialPage,
        currentPage: 1,
        hasReachedMax: true,
        selectedCategory: 'technology',
      ),
    ],
    verify: (_) {
      verify(() => mockUseCase(
            const HeadlinesParams(page: 1, category: 'technology'),
          )).called(1);
    },
  );
}
