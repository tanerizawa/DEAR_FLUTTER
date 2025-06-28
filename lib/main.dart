// lib/main.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/home/screens/home_screen.dart'; // <-- Pastikan import ini ada
import 'package:flutter/material.dart';

void main() {
  // Panggil ini sebelum runApp()
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // <-- Ini sudah benar
    );
  }
}