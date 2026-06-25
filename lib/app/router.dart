import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/splash/splash_screen.dart';
import '../features/main_menu/main_menu_screen.dart';
import '../features/level_select/level_select_screen.dart';
import '../features/puzzle/puzzle_screen.dart';
import '../features/completion/completion_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/instructions/instructions_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (_, state) => _fade(state, const SplashScreen()),
    ),
    GoRoute(
      path: '/menu',
      pageBuilder: (_, state) => _fade(state, const MainMenuScreen()),
    ),
    GoRoute(
      path: '/levels',
      pageBuilder: (_, state) => _slide(state, const LevelSelectScreen()),
    ),
    GoRoute(
      path: '/puzzle/:id',
      pageBuilder: (_, state) {
        final id = state.pathParameters['id']!;
        return _slide(state, PuzzleScreen(puzzleId: id));
      },
    ),
    GoRoute(
      path: '/completion/:id',
      pageBuilder: (_, state) {
        final id = state.pathParameters['id']!;
        return _fade(state, CompletionScreen(puzzleId: id));
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (_, state) => _slide(state, const SettingsScreen()),
    ),
    GoRoute(
      path: '/instructions',
      pageBuilder: (_, state) => _fade(state, const InstructionsScreen()),
    ),
  ],
);

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
      child: child,
    ),
  );
}

CustomTransitionPage<void> _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, __, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0.06, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
