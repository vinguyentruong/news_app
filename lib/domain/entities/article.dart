// lib/domain/entities/article.dart
import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String id; // derived from url
  final String title;
  final String? description;
  final String url;
  final String? imageUrl;
  final String? content;
  final String? author;
  final String sourceName;
  final DateTime publishedAt;

  const Article({
    required this.id,
    required this.title,
    this.description,
    required this.url,
    this.imageUrl,
    this.content,
    this.author,
    required this.sourceName,
    required this.publishedAt,
  });

  @override
  List<Object?> get props => [id, title, url, publishedAt];
}
