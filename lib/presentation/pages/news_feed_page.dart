// lib/presentation/pages/news_feed_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/article.dart';
import '../blocs/news_feed/news_feed_bloc.dart';
import '../cubits/bookmark/bookmark_cubit.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';
import '../widgets/shimmer_article_card.dart';
import 'article_detail_page.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({super.key});

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final _scrollController = ScrollController();

  static const _categories = [
    (label: 'All', value: null),
    (label: 'Business', value: 'business'),
    (label: 'Tech', value: 'technology'),
    (label: 'Sports', value: 'sports'),
    (label: 'Health', value: 'health'),
    (label: 'Science', value: 'science'),
    (label: 'Entertainment', value: 'entertainment'),
  ];

  @override
  void initState() {
    super.initState();
    context.read<NewsFeedBloc>().add(const NewsFeedStarted());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NewsFeedBloc>().add(const NewsFeedNextPageFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, _) => [
          _buildAppBar(context),
          _buildCategoryBar(context),
        ],
        body: BlocBuilder<NewsFeedBloc, NewsFeedState>(
          builder: (context, state) {
            return switch (state.status) {
              NewsFeedStatus.initial ||
              NewsFeedStatus.loading =>
                _buildShimmer(),
              NewsFeedStatus.failure when state.articles.isEmpty =>
                ErrorView(
                  message: state.errorMessage ?? 'Unknown error',
                  onRetry: () =>
                      context.read<NewsFeedBloc>().add(const NewsFeedRefreshed()),
                ),
              _ => _buildArticleList(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      title: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'NEWS',
              style: TextStyle(
                color: Color(0xFFE63946),
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            TextSpan(
              text: 'PULSE',
              style: TextStyle(
                color: Color(0xFFF5F5F5),
                fontSize: 24,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<NewsFeedBloc, NewsFeedState>(
        buildWhen: (prev, curr) => prev.selectedCategory != curr.selectedCategory,
        builder: (context, state) {
          return SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = state.selectedCategory == cat.value;
                return ChoiceChip(
                  label: Text(cat.label),
                  selected: selected,
                  onSelected: (_) => context
                      .read<NewsFeedBloc>()
                      .add(NewsFeedCategoryChanged(cat.value)),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF9E9E9E),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: AppConstants.shimmerItemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => const ShimmerArticleCard(),
    );
  }

  Widget _buildArticleList(BuildContext context, NewsFeedState state) {
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: const Color(0xFF1A1A1A),
      onRefresh: () async {
        context.read<NewsFeedBloc>().add(const NewsFeedRefreshed());
        await context.read<NewsFeedBloc>().stream.firstWhere(
              (s) => s.status == NewsFeedStatus.success ||
                  s.status == NewsFeedStatus.failure,
            );
      },
      child: AnimationLimiter(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.articles.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index >= state.articles.length) {
              return _buildListFooter(state);
            }
            final article = state.articles[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 30,
                child: FadeInAnimation(
                  child: _buildCard(context, article),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Article article) {
    return BlocBuilder<BookmarkCubit, BookmarkState>(
      buildWhen: (prev, curr) {
        final wasBookmarked = prev.bookmarks.any((a) => a.id == article.id);
        final isBookmarkedNow = curr.bookmarks.any((a) => a.id == article.id);
        return wasBookmarked != isBookmarkedNow;
      },
      builder: (context, bookmarkState) {
        final isBookmarked = bookmarkState.bookmarks.any((a) => a.id == article.id);
        return ArticleCard(
          article: article,
          isBookmarked: isBookmarked,
          onTap: () => _openArticle(context, article),
          onBookmarkTap: () =>
              context.read<BookmarkCubit>().toggleBookmark(article),
        );
      },
    );
  }

  Widget _buildListFooter(NewsFeedState state) {
    if (state.status == NewsFeedStatus.loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.hasReachedMax) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'You\'re all caught up',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ),
      );
    }
    return const SizedBox(height: 24);
  }

  void _openArticle(BuildContext context, Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailPage(article: article),
      ),
    );
  }
}
