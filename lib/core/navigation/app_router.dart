import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/usecases/get_auth_status_usecase.dart';
import 'package:dear_flutter/presentation/auth/screens/login_screen.dart';
import 'package:dear_flutter/presentation/auth/screens/register_screen.dart';
import 'package:dear_flutter/presentation/chat/screens/chat_screen.dart';
import 'package:dear_flutter/presentation/home/screens/home_screen.dart';
import 'package:dear_flutter/presentation/main/main_screen.dart';
import 'package:dear_flutter/presentation/profile/screens/profile_screen.dart'; // Sudah ditambahkan
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
