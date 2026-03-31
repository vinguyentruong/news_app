// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart';
import 'presentation/cubits/bookmark/bookmark_cubit.dart';
import 'presentation/pages/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables before anything else
  await dotenv.load(fileName: '.env');

  // Lock to portrait on phones; allow landscape on tablets
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  // Bootstrap DI graph
  await initDependencies();

  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // BookmarkCubit is provided at the root so its state (and Hive box)
      // is shared across all tabs without re-creating it on navigation.
      create: (_) => sl<BookmarkCubit>(),
      child: MaterialApp(
        title: 'NewsPulse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const MainPage(),
      ),
    );
  }
}
