// lib/domain/usecases/search_articles.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/utils/usecase.dart';
import '../entities/article.dart';
import '../repositories/news_repository.dart';

class SearchArticles extends UseCase<List<Article>, SearchParams> {
  final NewsRepository repository;
  SearchArticles(this.repository);

  @override
  Future<Either<Failure, List<Article>>> call(SearchParams params) {
    return repository.searchArticles(
      query: params.query,
      page: params.page,
    );
  }
}

class SearchParams extends Equatable {
  final String query;
  final int page;

  const SearchParams({required this.query, required this.page});

  @override
  List<Object> get props => [query, page];
}
