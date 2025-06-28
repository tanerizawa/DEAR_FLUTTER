import 'package:flutter/material.dart';
import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/core/navigation/app_router.dart'; // Router konfigurasi

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi dependency injection (getIt, dll.)
  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router, // Menggunakan GoRouter yang sudah dikonfigurasi
      debugShowCheckedModeBanner: false,
      title: 'Dear App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}
