// lib/presentation/pages/article_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/article.dart';
import '../cubits/article_detail/article_detail_cubit.dart';
import '../cubits/bookmark/bookmark_cubit.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArticleDetailCubit(article),
      child: _ArticleDetailView(article: article),
    );
  }
}

class _ArticleDetailView extends StatefulWidget {
  final Article article;

  const _ArticleDetailView({required this.article});

  @override
  State<_ArticleDetailView> createState() => _ArticleDetailViewState();
}

class _ArticleDetailViewState extends State<_ArticleDetailView> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A0A0A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            context
                .read<ArticleDetailCubit>()
                .updateLoadingProgress(progress / 100.0);
          },
          onPageFinished: (_) {
            context.read<ArticleDetailCubit>().setWebViewReady();
          },
          onWebResourceError: (error) {
            context.read<ArticleDetailCubit>().setError(
                  'Failed to load article: ${error.description}',
                );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.article.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocBuilder<ArticleDetailCubit, ArticleDetailState>(
        builder: (context, state) {
          return Stack(
            children: [
              WebViewWidget(controller: _webViewController),
              if (!state.isWebViewLoaded)
                LinearProgressIndicator(
                  value: state.loadingProgress > 0 ? state.loadingProgress : null,
                  backgroundColor: Colors.transparent,
                  color: Theme.of(context).colorScheme.primary,
                  minHeight: 3,
                ),
              if (state.error != null)
                _buildErrorFallback(context, state),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        widget.article.sourceName,
        style: const TextStyle(fontSize: 16),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        BlocBuilder<BookmarkCubit, BookmarkState>(
          builder: (context, state) {
            final isBookmarked =
                state.bookmarks.any((a) => a.id == widget.article.id);
            return IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  key: ValueKey(isBookmarked),
                  color: isBookmarked
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              onPressed: () {
                context.read<BookmarkCubit>().toggleBookmark(widget.article);
                final nowBookmarked = !isBookmarked;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      nowBookmarked ? 'Bookmarked' : 'Bookmark removed',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorFallback(BuildContext context, ArticleDetailState state) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.public_off_rounded,
                  size: 56, color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                'Cannot load article',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.error ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  _webViewController.reload();
                  context.read<ArticleDetailCubit>().updateLoadingProgress(0);
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
