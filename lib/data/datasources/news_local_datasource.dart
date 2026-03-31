// lib/data/datasources/news_local_datasource.dart
import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../models/article_model.dart';

abstract class NewsLocalDataSource {
  // Cache
  Future<void> cacheArticles(String cacheKey, List<ArticleModel> articles);
  Future<List<ArticleModel>> getCachedArticles(String cacheKey);
  bool isCacheValid(String cacheKey);

  // Bookmarks
  List<ArticleModel> getBookmarks();
  Future<void> addBookmark(ArticleModel article);
  Future<void> removeBookmark(String articleId);
  bool isBookmarked(String articleId);
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final Box<ArticleModel> bookmarksBox;
  final Box<dynamic> cacheBox;

  NewsLocalDataSourceImpl({
    required this.bookmarksBox,
    required this.cacheBox,
  });

  // ─── Cache ────────────────────────────────────────────────────────────────

  @override
  Future<void> cacheArticles(String cacheKey, List<ArticleModel> articles) async {
    try {
      final jsonList = articles.map((a) => jsonEncode(a.toJson())).toList();
      await cacheBox.put(cacheKey, jsonList);
      await cacheBox.put(
        '${AppConstants.cacheTimestampKey}$cacheKey',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      throw const CacheException(message: 'Failed to cache articles');
    }
  }

  @override
  Future<List<ArticleModel>> getCachedArticles(String cacheKey) async {
    try {
      final jsonList = cacheBox.get(cacheKey) as List?;
      if (jsonList == null) throw const CacheException(message: 'No cached data');
      return jsonList
          .map((s) => ArticleModel.fromJson(jsonDecode(s as String) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw const CacheException(message: 'Failed to read cache');
    }
  }

  @override
  bool isCacheValid(String cacheKey) {
    final timestamp = cacheBox.get('${AppConstants.cacheTimestampKey}$cacheKey') as int?;
    if (timestamp == null) return false;
    final cached = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cached) < AppConstants.cacheTtl;
  }

  // ─── Bookmarks ───────────────────────────────────────────────────────────

  @override
  List<ArticleModel> getBookmarks() {
    return bookmarksBox.values.toList();
  }

  @override
  Future<void> addBookmark(ArticleModel article) async {
    await bookmarksBox.put(article.id, article);
  }

  @override
  Future<void> removeBookmark(String articleId) async {
    await bookmarksBox.delete(articleId);
  }

  @override
  bool isBookmarked(String articleId) {
    return bookmarksBox.containsKey(articleId);
  }
}
