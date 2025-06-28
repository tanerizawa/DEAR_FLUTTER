// lib/main.dart

import 'package:flutter/material.dart';
import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/auth/screens/login_screen.dart'; // <-- Import login screen

Future<void> main() async {
  // Pastikan jembatan ke platform asli sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi dependency injection
  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dear App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // <-- Diganti ke LoginScreen
    );
  }
}
