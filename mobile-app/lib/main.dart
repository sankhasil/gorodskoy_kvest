import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/puzzle_list_screen.dart';
import 'screens/puzzle_game_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/puzzle_editor_screen.dart';
import 'screens/admin/clue_editor_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TreasureHuntApp()));
}

class TreasureHuntApp extends ConsumerWidget {
  const TreasureHuntApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return MaterialApp.router(
      title: 'Treasure Hunt',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: _buildRouter(authState),
    );
  }

  ThemeData _buildTheme() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4A017),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.cinzelTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: const Color(0xFFD4A017),
        ),
      );

  GoRouter _buildRouter(AuthState authState) => GoRouter(
        initialLocation: authState.isLoggedIn ? '/puzzles' : '/login',
        redirect: (context, state) {
          final loggedIn = authState.isLoggedIn;
          final onLogin = state.matchedLocation == '/login';
          if (!loggedIn && !onLogin) return '/login';
          if (loggedIn && onLogin) {
            return authState.isAdmin ? '/admin' : '/puzzles';
          }
          return null;
        },
        routes: [
          GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
          GoRoute(path: '/puzzles', builder: (_, __) => const PuzzleListScreen()),
          GoRoute(
            path: '/puzzles/:id/play',
            builder: (_, state) => PuzzleGameScreen(puzzleId: state.pathParameters['id']!),
          ),
          // Admin routes (role-gated in router + backend)
          GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
          GoRoute(
            path: '/admin/puzzles/new',
            builder: (_, __) => const PuzzleEditorScreen(),
          ),
          GoRoute(
            path: '/admin/puzzles/:id/edit',
            builder: (_, state) => PuzzleEditorScreen(puzzleId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/admin/puzzles/:id/clues',
            builder: (_, state) => ClueEditorScreen(puzzleId: state.pathParameters['id']!),
          ),
        ],
      );
}
