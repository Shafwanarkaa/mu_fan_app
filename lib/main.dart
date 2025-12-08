import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/forum_provider.dart';

// Placeholder screens for routing setup
import 'screens/loading_screen.dart';
import 'screens/home_screen.dart';
import 'screens/squad_screen.dart';
import 'screens/standings_screen.dart';
import 'screens/fixtures_screen.dart';
import 'screens/news_screen.dart';
import 'screens/forum_screen.dart';
import 'widgets/main_layout.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ForumProvider())],
      child: const MuFanApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoadingScreen()),
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const HomeScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
        ),
        GoRoute(
          path: '/squad',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const SquadScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
        ),
        GoRoute(
          path: '/standings',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const StandingsScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
        ),
        GoRoute(
          path: '/fixtures',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const FixturesScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
        ),
        GoRoute(
          path: '/news',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const NewsScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
        ),
        GoRoute(
          path: '/forum',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ForumScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
        ),
      ],
    ),
  ],
);

class MuFanApp extends StatelessWidget {
  const MuFanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MU Fan App',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
