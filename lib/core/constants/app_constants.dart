// lib/core/constants/app_constants.dart
class AppConstants {
  AppConstants._();

  // API
  static const int pageSize = 20;
  static const Duration requestTimeout = Duration(seconds: 15);

  // Cache
  static const String articlesCacheBox = 'articles_cache';
  static const String bookmarksBox = 'bookmarks_box';
  static const Duration cacheTtl = Duration(minutes: 15);
  static const String cacheTimestampKey = 'cache_timestamp_';

  // UI
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const int shimmerItemCount = 8;
}
