import 'package:go_router/go_router.dart';

import '../features/splash/splash_screen.dart';
import '../features/main_menu/main_menu_screen.dart';
import '../features/level_select/level_select_screen.dart';
import '../features/puzzle/puzzle_screen.dart';
import '../features/completion/completion_screen.dart';
import '../features/settings/settings_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/menu',
      builder: (_, __) => const MainMenuScreen(),
    ),
    GoRoute(
      path: '/levels',
      builder: (_, __) => const LevelSelectScreen(),
    ),
    GoRoute(
      path: '/puzzle/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PuzzleScreen(puzzleId: id);
      },
    ),
    GoRoute(
      path: '/completion/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return CompletionScreen(puzzleId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
  ],
);
