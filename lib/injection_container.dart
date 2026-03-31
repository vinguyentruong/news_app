// lib/injection_container.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'data/datasources/news_local_datasource.dart';
import 'data/datasources/news_remote_datasource.dart';
import 'data/models/article_model.dart';
import 'data/repositories/news_repository_impl.dart';
import 'domain/repositories/news_repository.dart';
import 'domain/usecases/bookmark_usecases.dart';
import 'domain/usecases/get_top_headlines.dart';
import 'domain/usecases/search_articles.dart';
import 'presentation/blocs/news_feed/news_feed_bloc.dart';
import 'presentation/blocs/search/search_bloc.dart';
import 'presentation/cubits/bookmark/bookmark_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── Hive ─────────────────────────────────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(ArticleModelAdapter());

  final bookmarksBox = await Hive.openBox<ArticleModel>(AppConstants.bookmarksBox);
  final cacheBox = await Hive.openBox<dynamic>(AppConstants.articlesCacheBox);

  // ─── External ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => DioClient());

  // ─── Core ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // ─── Data Sources ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<NewsLocalDataSource>(
    () => NewsLocalDataSourceImpl(
      bookmarksBox: bookmarksBox,
      cacheBox: cacheBox,
    ),
  );

  // ─── Repository ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ─── Use Cases ────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetTopHeadlines(sl()));
  sl.registerLazySingleton(() => SearchArticles(sl()));
  sl.registerLazySingleton(() => GetBookmarks(sl()));
  sl.registerLazySingleton(() => AddBookmark(sl()));
  sl.registerLazySingleton(() => RemoveBookmark(sl()));
  sl.registerLazySingleton(() => IsBookmarked(sl()));

  // ─── BLoCs / Cubits (factories so each screen gets fresh instance) ────────
  sl.registerFactory(
    () => NewsFeedBloc(getTopHeadlines: sl()),
  );
  sl.registerFactory(
    () => SearchBloc(searchArticles: sl()),
  );
  // BookmarkCubit is singleton so bookmark state persists across tabs
  sl.registerLazySingleton(
    () => BookmarkCubit(
      getBookmarks: sl(),
      addBookmark: sl(),
      removeBookmark: sl(),
      isBookmarked: sl(),
    ),
  );
}
