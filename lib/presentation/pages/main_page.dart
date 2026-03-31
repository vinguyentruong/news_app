// lib/presentation/pages/main_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection_container.dart';
import '../blocs/news_feed/news_feed_bloc.dart';
import '../blocs/search/search_bloc.dart';
import 'bookmarks_page.dart';
import 'news_feed_page.dart';
import 'search_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Feed',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search_rounded),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.bookmark_outline_rounded),
      selectedIcon: Icon(Icons.bookmark_rounded),
      label: 'Saved',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BlocProvider(
            create: (_) => sl<NewsFeedBloc>(),
            child: const NewsFeedPage(),
          ),
          BlocProvider(
            create: (_) => sl<SearchBloc>(),
            child: const SearchPage(),
          ),
          const BookmarksPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: const Color(0xFF111111),
        indicatorColor: const Color(0xFFE63946),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _destinations,
      ),
    );
  }
}
