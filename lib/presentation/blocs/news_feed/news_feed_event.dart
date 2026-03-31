// lib/presentation/blocs/news_feed/news_feed_event.dart
part of 'news_feed_bloc.dart';

abstract class NewsFeedEvent extends Equatable {
  const NewsFeedEvent();

  @override
  List<Object?> get props => [];
}

class NewsFeedStarted extends NewsFeedEvent {
  const NewsFeedStarted();
}

class NewsFeedRefreshed extends NewsFeedEvent {
  const NewsFeedRefreshed();
}

class NewsFeedNextPageFetched extends NewsFeedEvent {
  const NewsFeedNextPageFetched();
}

class NewsFeedCategoryChanged extends NewsFeedEvent {
  final String? category;
  const NewsFeedCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}
