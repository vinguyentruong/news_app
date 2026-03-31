// lib/data/datasources/news_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../models/article_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<ArticleModel>> getTopHeadlines({required int page, String? category});
  Future<List<ArticleModel>> searchArticles({required String query, required int page});
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;

  NewsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ArticleModel>> getTopHeadlines({
    required int page,
    String? category,
  }) async {
    try {
      final response = await dio.get(
        '/top-headlines',
        queryParameters: {
          'country': 'us',
          'pageSize': AppConstants.pageSize,
          'page': page,
          if (category != null) 'category': category,
        },
      );
      return _parseArticles(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    }
    throw const ServerException();
  }

  @override
  Future<List<ArticleModel>> searchArticles({
    required String query,
    required int page,
  }) async {
    try {
      final response = await dio.get(
        '/everything',
        queryParameters: {
          'q': query,
          'pageSize': AppConstants.pageSize,
          'page': page,
          'sortBy': 'publishedAt',
          'language': 'en',
        },
      );
      return _parseArticles(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    }
    throw const ServerException();
  }

  List<ArticleModel> _parseArticles(dynamic data) {
    if (data == null || data['articles'] == null) {
      throw const ServerException(message: 'Invalid response format');
    }
    final articles = data['articles'] as List<dynamic>;
    return articles
        .map((json) => ArticleModel.fromJson(json as Map<String, dynamic>))
        .where((a) => a.title != '[Removed]' && a.url.isNotEmpty)
        .toList();
  }

  Never _handleDioError(DioException e) {
    final error = e.error;
    if (error is NetworkException) throw error;
    if (error is UnauthorizedException) throw error;
    if (error is ServerException) throw error;
    throw ServerException(message: e.message ?? 'Unknown error');
  }
}
