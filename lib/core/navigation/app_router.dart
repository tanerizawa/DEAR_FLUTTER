import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/usecases/get_auth_status_usecase.dart';
import 'package:dear_flutter/presentation/auth/screens/login_screen.dart';
import 'package:dear_flutter/presentation/auth/screens/register_screen.dart';
import 'package:dear_flutter/presentation/chat/screens/chat_screen.dart';
import 'package:dear_flutter/presentation/home/screens/home_screen.dart';
import 'package:dear_flutter/presentation/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Kunci Global untuk ShellRoute agar state tetap terjaga
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  initialLocation: '/home',
  navigatorKey: _rootNavigatorKey,
  routes: [
    // Rute untuk alur utama (dengan BottomNavigationBar)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // "Bungkus" semua halaman utama dengan MainScreen
        return MainScreen(child: navigationShell);
      },
      branches: [
        // Branch untuk tab pertama (Beranda)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Branch untuk tab kedua (Chat)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatScreen(),
            ),
          ],
        ),
      ],
    ),

    // Rute untuk halaman yang tidak memiliki BottomNavigationBar
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
  redirect: (context, state) {
    final isLoggedIn = getIt<GetAuthStatusUseCase>().call();
    final isGoingToLogin = state.matchedLocation == '/login';

    // Jika belum login dan tidak sedang menuju halaman login, belokkan ke /login
    if (!isLoggedIn && !isGoingToLogin) {
      return '/login';
    }

    // Jika sudah login dan mencoba ke halaman login, belokkan ke /home
    if (isLoggedIn && isGoingToLogin) {
      return '/home';
    }

    return null; // Lanjutkan ke tujuan
  },
);

