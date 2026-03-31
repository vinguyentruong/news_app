// test/data/models/article_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/data/models/article_model.dart';
import 'package:news_app/domain/entities/article.dart';

void main() {
  final tJson = {
    'title': 'Test Article',
    'description': 'A description',
    'url': 'https://example.com/article',
    'urlToImage': 'https://example.com/image.jpg',
    'content': 'Full content here',
    'author': 'John Doe',
    'source': {'id': 'bbc', 'name': 'BBC News'},
    'publishedAt': '2024-06-15T10:00:00Z',
  };

  group('ArticleModel.fromJson', () {
    test('parses all fields correctly', () {
      final model = ArticleModel.fromJson(tJson);
      expect(model.title, 'Test Article');
      expect(model.description, 'A description');
      expect(model.url, 'https://example.com/article');
      expect(model.imageUrl, 'https://example.com/image.jpg');
      expect(model.author, 'John Doe');
      expect(model.sourceName, 'BBC News');
      expect(model.publishedAt, DateTime.parse('2024-06-15T10:00:00Z'));
    });

    test('id is derived from url hash', () {
      final model = ArticleModel.fromJson(tJson);
      expect(model.id, 'https://example.com/article'.hashCode.toString());
    });

    test('handles null optional fields gracefully', () {
      final json = {
        'title': 'Test',
        'url': 'https://example.com',
        'source': {'name': 'Source'},
        'publishedAt': '2024-01-01T00:00:00Z',
      };
      final model = ArticleModel.fromJson(json);
      expect(model.description, isNull);
      expect(model.imageUrl, isNull);
      expect(model.author, isNull);
    });

    test('uses Unknown when source name is missing', () {
      final json = {
        'title': 'Test',
        'url': 'https://example.com',
        'source': {},
        'publishedAt': '2024-01-01T00:00:00Z',
      };
      final model = ArticleModel.fromJson(json);
      expect(model.sourceName, 'Unknown');
    });

    test('uses No title for null title', () {
      final json = {
        'url': 'https://example.com',
        'source': {'name': 'Source'},
        'publishedAt': '2024-01-01T00:00:00Z',
      };
      final model = ArticleModel.fromJson(json);
      expect(model.title, 'No title');
    });
  });

  group('ArticleModel.toEntity', () {
    test('maps to Article entity correctly', () {
      final model = ArticleModel.fromJson(tJson);
      final entity = model.toEntity();
      expect(entity, isA<Article>());
      expect(entity.title, model.title);
      expect(entity.url, model.url);
      expect(entity.sourceName, model.sourceName);
    });
  });

  group('ArticleModel.fromEntity', () {
    test('round-trips through entity without data loss', () {
      final original = ArticleModel.fromJson(tJson);
      final entity = original.toEntity();
      final restored = ArticleModel.fromEntity(entity);
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.url, original.url);
      expect(restored.sourceName, original.sourceName);
      expect(restored.publishedAt, original.publishedAt);
    });
  });

  group('ArticleModel.toJson', () {
    test('serialises and deserialises without data loss', () {
      final original = ArticleModel.fromJson(tJson);
      final json = original.toJson();
      final restored = ArticleModel.fromJson(json);
      expect(restored.title, original.title);
      expect(restored.url, original.url);
      expect(restored.author, original.author);
    });
  });
}
