// test/presentation/blocs/search_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/domain/entities/article.dart';
import 'package:news_app/domain/usecases/search_articles.dart';
import 'package:news_app/presentation/blocs/search/search_bloc.dart';

class MockSearchArticles extends Mock implements SearchArticles {}

Article _makeArticle(int i) => Article(
      id: '$i',
      title: 'Result $i',
      url: 'https://example.com/$i',
      sourceName: 'Source',
      publishedAt: DateTime(2024),
    );

void main() {
  late SearchBloc bloc;
  late MockSearchArticles mockUseCase;

  final tResults = List.generate(5, _makeArticle);
  final fullPage = List.generate(20, _makeArticle);

  setUpAll(() {
    registerFallbackValue(const SearchParams(query: 'test', page: 1));
  });

  setUp(() {
    mockUseCase = MockSearchArticles();
    bloc = SearchBloc(searchArticles: mockUseCase);
  });

  tearDown(() => bloc.close());

  // ─── Initial state ────────────────────────────────────────────────────────

  test('initial state is correct', () {
    expect(bloc.state.status, SearchStatus.idle);
    expect(bloc.state.query, '');
    expect(bloc.state.articles, isEmpty);
  });

  // ─── SearchCleared ────────────────────────────────────────────────────────

  blocTest<SearchBloc, SearchState>(
    'SearchCleared resets state to idle',
    build: () => bloc,
    seed: () => SearchState(
      status: SearchStatus.success,
      query: 'flutter',
      articles: tResults,
    ),
    act: (b) => b.add(const SearchCleared()),
    expect: () => [const SearchState()],
  );

  // ─── SearchQueryChanged ───────────────────────────────────────────────────
  // Note: debounce is bypassed by bloc_test's sequential event processing

  blocTest<SearchBloc, SearchState>(
    'SearchQueryChanged with empty string resets to idle',
    build: () => bloc,
    act: (b) => b.add(const SearchQueryChanged('')),
    expect: () => [const SearchState()],
    verify: (_) => verifyNever(() => mockUseCase(any())),
  );

  blocTest<SearchBloc, SearchState>(
    'SearchQueryChanged with whitespace-only string resets to idle',
    build: () => bloc,
    act: (b) => b.add(const SearchQueryChanged('   ')),
    expect: () => [const SearchState()],
    verify: (_) => verifyNever(() => mockUseCase(any())),
  );

  blocTest<SearchBloc, SearchState>(
    'SearchQueryChanged emits [loading, success] on valid query',
    build: () {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(tResults));
      return bloc;
    },
    act: (b) => b.add(const SearchQueryChanged('flutter')),
    expect: () => [
      const SearchState(status: SearchStatus.loading, query: 'flutter'),
      SearchState(
        status: SearchStatus.success,
        query: 'flutter',
        articles: tResults,
        currentPage: 1,
        hasReachedMax: true,
      ),
    ],
    verify: (_) {
      verify(() =>
              mockUseCase(const SearchParams(query: 'flutter', page: 1)))
          .called(1);
    },
  );

  blocTest<SearchBloc, SearchState>(
    'SearchQueryChanged emits [loading, failure] on error',
    build: () {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => const Left(NetworkFailure()));
      return bloc;
    },
    act: (b) => b.add(const SearchQueryChanged('error test')),
    expect: () => [
      isA<SearchState>().having((s) => s.status, 'status', SearchStatus.loading),
      isA<SearchState>()
          .having((s) => s.status, 'status', SearchStatus.failure)
          .having((s) => s.errorMessage, 'error', isNotNull),
    ],
  );

  // ─── SearchNextPageFetched ────────────────────────────────────────────────

  blocTest<SearchBloc, SearchState>(
    'SearchNextPageFetched appends next page of results',
    build: () {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => Right(fullPage));
      return bloc;
    },
    seed: () => SearchState(
      status: SearchStatus.success,
      query: 'flutter',
      articles: fullPage,
      currentPage: 1,
      hasReachedMax: false,
    ),
    act: (b) => b.add(const SearchNextPageFetched()),
    expect: () => [
      isA<SearchState>()
          .having((s) => s.status, 'status', SearchStatus.loadingMore),
      isA<SearchState>()
          .having((s) => s.articles.length, 'articles', 40)
          .having((s) => s.currentPage, 'page', 2),
    ],
    verify: (_) {
      verify(() =>
              mockUseCase(const SearchParams(query: 'flutter', page: 2)))
          .called(1);
    },
  );

  blocTest<SearchBloc, SearchState>(
    'SearchNextPageFetched ignored when hasReachedMax',
    build: () => bloc,
    seed: () => SearchState(
      status: SearchStatus.success,
      query: 'flutter',
      articles: tResults,
      currentPage: 1,
      hasReachedMax: true,
    ),
    act: (b) => b.add(const SearchNextPageFetched()),
    expect: () => <SearchState>[],
    verify: (_) => verifyNever(() => mockUseCase(any())),
  );

  blocTest<SearchBloc, SearchState>(
    'SearchNextPageFetched ignored when query is empty',
    build: () => bloc,
    seed: () => const SearchState(
      status: SearchStatus.idle,
      query: '',
    ),
    act: (b) => b.add(const SearchNextPageFetched()),
    expect: () => <SearchState>[],
    verify: (_) => verifyNever(() => mockUseCase(any())),
  );
}
