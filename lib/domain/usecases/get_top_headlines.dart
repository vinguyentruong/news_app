// lib/domain/usecases/get_top_headlines.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/utils/usecase.dart';
import '../entities/article.dart';
import '../repositories/news_repository.dart';

class GetTopHeadlines extends UseCase<List<Article>, HeadlinesParams> {
  final NewsRepository repository;
  GetTopHeadlines(this.repository);

  @override
  Future<Either<Failure, List<Article>>> call(HeadlinesParams params) {
    return repository.getTopHeadlines(
      page: params.page,
      category: params.category,
    );
  }
}

class HeadlinesParams extends Equatable {
  final int page;
  final String? category;

  const HeadlinesParams({required this.page, this.category});

  @override
  List<Object?> get props => [page, category];
}
