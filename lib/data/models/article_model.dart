// lib/data/models/article_model.dart
import 'package:hive/hive.dart';
import '../../domain/entities/article.dart';

part 'article_model.g.dart';

@HiveType(typeId: 0)
class ArticleModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String url;

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final String? content;

  @HiveField(6)
  final String? author;

  @HiveField(7)
  final String sourceName;

  @HiveField(8)
  final DateTime publishedAt;

  ArticleModel({
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

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String? ?? '';
    return ArticleModel(
      id: url.hashCode.toString(),
      title: json['title'] as String? ?? 'No title',
      description: json['description'] as String?,
      url: url,
      imageUrl: json['urlToImage'] as String?,
      content: json['content'] as String?,
      author: json['author'] as String?,
      sourceName: (json['source'] as Map<String, dynamic>?)?['name'] as String? ?? 'Unknown',
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  factory ArticleModel.fromEntity(Article article) {
    return ArticleModel(
      id: article.id,
      title: article.title,
      description: article.description,
      url: article.url,
      imageUrl: article.imageUrl,
      content: article.content,
      author: article.author,
      sourceName: article.sourceName,
      publishedAt: article.publishedAt,
    );
  }

  Article toEntity() {
    return Article(
      id: id,
      title: title,
      description: description,
      url: url,
      imageUrl: imageUrl,
      content: content,
      author: author,
      sourceName: sourceName,
      publishedAt: publishedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'url': url,
        'urlToImage': imageUrl,
        'content': content,
        'author': author,
        'source': {'name': sourceName},
        'publishedAt': publishedAt.toIso8601String(),
      };
}
