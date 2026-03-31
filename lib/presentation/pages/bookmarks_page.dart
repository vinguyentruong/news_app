// lib/presentation/pages/bookmarks_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../domain/entities/article.dart';
import '../cubits/bookmark/bookmark_cubit.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';
import 'article_detail_page.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Articles'),
      ),
      body: BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, state) {
          if (state.bookmarks.isEmpty) {
            return const EmptyView(
              title: 'No bookmarks yet',
              subtitle:
                  'Tap the bookmark icon on any article\nto save it for offline reading.',
              icon: Icons.bookmark_outline_rounded,
            );
          }

          return AnimationLimiter(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.bookmarks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final article = state.bookmarks[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 20,
                    child: FadeInAnimation(
                      child: _BookmarkCard(article: article),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final Article article;
  const _BookmarkCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(article.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        context.read<BookmarkCubit>().toggleBookmark(article);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bookmark removed'),
            action: SnackBarAction(
              label: 'Undo',
              textColor: const Color(0xFFE63946),
              onPressed: () =>
                  context.read<BookmarkCubit>().toggleBookmark(article),
            ),
          ),
        );
      },
      child: ArticleCard(
        article: article,
        isBookmarked: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailPage(article: article),
          ),
        ),
        onBookmarkTap: () =>
            context.read<BookmarkCubit>().toggleBookmark(article),
      ),
    );
  }
}
