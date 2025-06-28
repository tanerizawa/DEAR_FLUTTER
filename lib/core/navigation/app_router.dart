import 'package:dear_flutter/presentation/auth/screens/login_screen.dart';
import 'package:dear_flutter/presentation/auth/screens/register_screen.dart'; // <-- Akan kita buat
import 'package:dear_flutter/presentation/home/screens/home_screen.dart';
import 'package:go_router/go_router.dart';

// Konfigurasi GoRouter
final GoRouter router = GoRouter(
  // Rute awal aplikasi
  initialLocation: '/login',
  // Daftar semua rute yang tersedia
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(), // <-- Rute baru
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
