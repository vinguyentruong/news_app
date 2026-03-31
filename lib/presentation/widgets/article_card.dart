// lib/presentation/widgets/article_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/entities/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null) _buildImage(context),
            _buildBody(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: article.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: const Color(0xFF2A2A2A),
          child: const Center(
            child: Icon(Icons.image_outlined, color: Colors.white24, size: 40),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: const Color(0xFF2A2A2A),
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 40),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source + time row
          Row(
            children: [
              Expanded(
                child: Text(
                  article.sourceName.toUpperCase(),
                  style: theme.textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                timeago.format(article.publishedAt),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            article.title,
            style: theme.textTheme.headlineMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (article.description != null && article.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              article.description!,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          // Footer
          Row(
            children: [
              if (article.author != null && article.author!.isNotEmpty)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 13, color: Colors.white38),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          article.author!,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Spacer(),
              GestureDetector(
                onTap: onBookmarkTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      key: ValueKey(isBookmarked),
                      color: isBookmarked
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white38,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
