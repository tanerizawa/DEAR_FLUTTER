import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/core/navigation/app_router.dart'; // <-- IMPORT BARU
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan MaterialApp.router
    return MaterialApp.router(
      routerConfig: router, // <-- Berikan konfigurasi router kita
      debugShowCheckedModeBanner: false,
      title: 'Dear App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}