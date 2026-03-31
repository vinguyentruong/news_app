// lib/presentation/pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../domain/entities/article.dart';
import '../blocs/search/search_bloc.dart';
import '../cubits/bookmark/bookmark_cubit.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';
import '../widgets/shimmer_article_card.dart';
import 'article_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _queryController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchBloc>().add(const SearchNextPageFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _queryController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Color(0xFFF5F5F5)),
              decoration: InputDecoration(
                hintText: 'Search for news...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: BlocBuilder<SearchBloc, SearchState>(
                  buildWhen: (p, c) => (p.query.isEmpty) != (c.query.isEmpty),
                  builder: (context, state) {
                    if (state.query.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _queryController.clear();
                        context.read<SearchBloc>().add(const SearchCleared());
                      },
                    );
                  },
                ),
              ),
              onChanged: (query) {
                context.read<SearchBloc>().add(SearchQueryChanged(query));
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return switch (state.status) {
            SearchStatus.idle => _buildIdle(context),
            SearchStatus.loading => _buildShimmer(),
            SearchStatus.failure => ErrorView(
                message: state.errorMessage ?? 'Search failed',
                onRetry: () => context
                    .read<SearchBloc>()
                    .add(SearchQueryChanged(_queryController.text)),
              ),
            SearchStatus.success when state.articles.isEmpty => EmptyView(
                title: 'No results',
                subtitle: 'Try a different search term',
                icon: Icons.search_off_rounded,
              ),
            _ => _buildResults(context, state),
          };
        },
      ),
    );
  }

  Widget _buildIdle(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_rounded, size: 64, color: Colors.white12),
          const SizedBox(height: 16),
          Text(
            'Search the news',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white38,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start typing to find articles',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => const ShimmerArticleCard(),
    );
  }

  Widget _buildResults(BuildContext context, SearchState state) {
    return AnimationLimiter(
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.articles.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index >= state.articles.length) {
            return _buildFooter(state);
          }
          final article = state.articles[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 350),
            child: SlideAnimation(
              verticalOffset: 20,
              child: FadeInAnimation(child: _buildCard(context, article)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, Article article) {
    return BlocBuilder<BookmarkCubit, BookmarkState>(
      buildWhen: (prev, curr) {
        final was = prev.bookmarks.any((a) => a.id == article.id);
        final now = curr.bookmarks.any((a) => a.id == article.id);
        return was != now;
      },
      builder: (context, bookmarkState) {
        final isBookmarked =
            bookmarkState.bookmarks.any((a) => a.id == article.id);
        return ArticleCard(
          article: article,
          isBookmarked: isBookmarked,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ArticleDetailPage(article: article),
            ),
          ),
          onBookmarkTap: () =>
              context.read<BookmarkCubit>().toggleBookmark(article),
        );
      },
    );
  }

  Widget _buildFooter(SearchState state) {
    if (state.status == SearchStatus.loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.hasReachedMax && state.articles.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'End of results',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ),
      );
    }
    return const SizedBox(height: 24);
  }
}
