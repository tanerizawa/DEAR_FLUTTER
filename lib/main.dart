import 'package:flutter/material.dart';
import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/core/navigation/app_router.dart'; // Router konfigurasi
import 'package:dear_flutter/services/notification_service.dart';
import 'package:dear_flutter/services/quote_update_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi dependency injection (getIt, dll.)
  await configureDependencies();
  await getIt<NotificationService>().init();
  getIt<QuoteUpdateService>().start();

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
