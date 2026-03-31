// test/presentation/cubits/bookmark_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/domain/entities/article.dart';
import 'package:news_app/domain/usecases/bookmark_usecases.dart';
import 'package:news_app/presentation/cubits/bookmark/bookmark_cubit.dart';

class MockGetBookmarks extends Mock implements GetBookmarks {}

class MockAddBookmark extends Mock implements AddBookmark {}

class MockRemoveBookmark extends Mock implements RemoveBookmark {}

class MockIsBookmarked extends Mock implements IsBookmarked {}

void main() {
  late BookmarkCubit cubit;
  late MockGetBookmarks mockGet;
  late MockAddBookmark mockAdd;
  late MockRemoveBookmark mockRemove;
  late MockIsBookmarked mockIsBookmarked;

  final tArticle = Article(
    id: '1',
    title: 'Test Article',
    url: 'https://example.com',
    sourceName: 'Test Source',
    publishedAt: DateTime(2024),
  );

  setUp(() {
    mockGet = MockGetBookmarks();
    mockAdd = MockAddBookmark();
    mockRemove = MockRemoveBookmark();
    mockIsBookmarked = MockIsBookmarked();

    when(() => mockGet()).thenReturn([]);
  });

  BookmarkCubit buildCubit() => BookmarkCubit(
        getBookmarks: mockGet,
        addBookmark: mockAdd,
        removeBookmark: mockRemove,
        isBookmarked: mockIsBookmarked,
      );

  tearDown(() => cubit.close());

  // ─── Initialization ───────────────────────────────────────────────────────

  test('initial state loads existing bookmarks from use case', () {
    when(() => mockGet()).thenReturn([tArticle]);
    cubit = buildCubit();
    expect(cubit.state.bookmarks, [tArticle]);
  });

  test('initial state is empty when no bookmarks exist', () {
    when(() => mockGet()).thenReturn([]);
    cubit = buildCubit();
    expect(cubit.state.bookmarks, isEmpty);
  });

  // ─── toggleBookmark — adding ──────────────────────────────────────────────

  blocTest<BookmarkCubit, BookmarkState>(
    'toggleBookmark adds article when not bookmarked',
    build: () {
      when(() => mockIsBookmarked(tArticle.id)).thenReturn(false);
      when(() => mockAdd(tArticle)).thenAnswer((_) async => const Right(unit));
      return buildCubit();
    },
    act: (c) => c.toggleBookmark(tArticle),
    expect: () => [
      isA<BookmarkState>().having(
        (s) => s.bookmarks,
        'bookmarks contains article',
        contains(tArticle),
      ),
    ],
    verify: (_) {
      verify(() => mockAdd(tArticle)).called(1);
    },
  );

  blocTest<BookmarkCubit, BookmarkState>(
    'toggleBookmark emits errorMessage when addBookmark fails',
    build: () {
      when(() => mockIsBookmarked(tArticle.id)).thenReturn(false);
      when(() => mockAdd(tArticle)).thenAnswer(
          (_) async => const Left(CacheFailure('Failed to save bookmark')));
      return buildCubit();
    },
    act: (c) => c.toggleBookmark(tArticle),
    expect: () => [
      isA<BookmarkState>().having(
        (s) => s.errorMessage,
        'errorMessage',
        'Failed to save bookmark',
      ),
    ],
  );

  // ─── toggleBookmark — removing ────────────────────────────────────────────

  blocTest<BookmarkCubit, BookmarkState>(
    'toggleBookmark removes article when already bookmarked',
    build: () {
      when(() => mockGet()).thenReturn([tArticle]);
      when(() => mockIsBookmarked(tArticle.id)).thenReturn(true);
      when(() => mockRemove(tArticle.id))
          .thenAnswer((_) async => const Right(unit));
      return buildCubit();
    },
    act: (c) => c.toggleBookmark(tArticle),
    expect: () => [
      isA<BookmarkState>().having(
        (s) => s.bookmarks,
        'bookmarks does not contain article',
        isNot(contains(tArticle)),
      ),
    ],
    verify: (_) {
      verify(() => mockRemove(tArticle.id)).called(1);
    },
  );

  blocTest<BookmarkCubit, BookmarkState>(
    'toggleBookmark emits errorMessage when removeBookmark fails',
    build: () {
      when(() => mockGet()).thenReturn([tArticle]);
      when(() => mockIsBookmarked(tArticle.id)).thenReturn(true);
      when(() => mockRemove(tArticle.id)).thenAnswer(
          (_) async => const Left(CacheFailure('Failed to remove')));
      return buildCubit();
    },
    act: (c) => c.toggleBookmark(tArticle),
    expect: () => [
      isA<BookmarkState>().having(
        (s) => s.errorMessage,
        'errorMessage',
        'Failed to remove',
      ),
    ],
  );

  // ─── checkIsBookmarked ────────────────────────────────────────────────────

  test('checkIsBookmarked delegates to IsBookmarked use case', () {
    when(() => mockIsBookmarked('1')).thenReturn(true);
    when(() => mockIsBookmarked('99')).thenReturn(false);
    cubit = buildCubit();

    expect(cubit.checkIsBookmarked('1'), isTrue);
    expect(cubit.checkIsBookmarked('99'), isFalse);
  });
}
