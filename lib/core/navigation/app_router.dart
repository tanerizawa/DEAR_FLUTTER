import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/usecases/get_auth_status_usecase.dart';
import 'package:dear_flutter/presentation/auth/screens/login_screen.dart';
import 'package:dear_flutter/presentation/auth/screens/register_screen.dart';
import 'package:dear_flutter/presentation/chat/screens/chat_screen.dart';
import 'package:dear_flutter/presentation/home/screens/home_screen.dart';
import 'package:dear_flutter/presentation/main/main_screen.dart';
import 'package:dear_flutter/presentation/profile/screens/profile_screen.dart'; // Sudah ditambahkan
import 'package:dear_flutter/presentation/home/screens/article_detail_screen.dart';
import 'package:dear_flutter/presentation/home/screens/audio_player_screen.dart';
import 'package:dear_flutter/presentation/home/screens/quote_detail_screen.dart';
import 'package:dear_flutter/domain/entities/article.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Navigator key utama
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  initialLocation: '/home',
  navigatorKey: _rootNavigatorKey,
  routes: [
    // ShellRoute dengan 3 tab utama
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(child: navigationShell);
      },
      branches: [
        // Tab 0: Beranda
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
          ],
        ),
        // Tab 1: Chat
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ChatScreen()),
            ),
          ],
        ),
        // Tab 2: Profil (tambahan)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ProfileScreen()),
            ),
          ],
        ),
      ],
    ),

    // Detail routes di luar shell
    GoRoute(
      path: '/article',
      builder: (context, state) =>
          ArticleDetailScreen(article: state.extra as Article),
    ),
    GoRoute(
      path: '/audio',
      builder: (context, state) =>
          AudioPlayerScreen(track: state.extra as AudioTrack),
    ),
    GoRoute(
      path: '/quote',
      builder: (context, state) =>
          QuoteDetailScreen(quote: state.extra as MotivationalQuote),
    ),

    // Route luar shell (autentikasi)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],

  // Redirect berdasarkan status login
  redirect: (context, state) {
    final isLoggedIn = getIt<GetAuthStatusUseCase>().call();
    final isGoingToAuthRoutes =
        state.matchedLocation == '/login' || state.matchedLocation == '/register';

    if (!isLoggedIn && !isGoingToAuthRoutes) {
      return '/login';
    }

    if (isLoggedIn && isGoingToAuthRoutes) {
      return '/home';
    }

    return null;
  },
);
