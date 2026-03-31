// lib/domain/usecases/bookmark_usecases.dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/article.dart';
import '../repositories/news_repository.dart';

class GetBookmarks {
  final NewsRepository repository;
  GetBookmarks(this.repository);

  List<Article> call() => repository.getBookmarks();
}

class AddBookmark {
  final NewsRepository repository;
  AddBookmark(this.repository);

  Future<Either<Failure, Unit>> call(Article article) =>
      repository.addBookmark(article);
}

class RemoveBookmark {
  final NewsRepository repository;
  RemoveBookmark(this.repository);

  Future<Either<Failure, Unit>> call(String articleId) =>
      repository.removeBookmark(articleId);
}

class IsBookmarked {
  final NewsRepository repository;
  IsBookmarked(this.repository);

  bool call(String articleId) => repository.isBookmarked(articleId);
}
