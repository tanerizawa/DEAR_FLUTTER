// lib/main.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/home/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  // VVVV  TAMBAHKAN BARIS INI  VVVV
  // Baris ini memastikan "jembatan" ke platform asli sudah siap.
  // Wajib ada sebelum memanggil plugin seperti path_provider.
  WidgetsFlutterBinding.ensureInitialized();
  // ^^^^ SAMPAI DI SINI ^^^^

  // Panggil ini setelah jembatan siap
  configureDependencies();

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
      home: const HomeScreen(),
    );
  }
}