import 'package:flutter/material.dart';
import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/core/navigation/app_router.dart'; // Router konfigurasi
import 'package:dear_flutter/services/notification_service.dart';
import 'package:dear_flutter/services/quote_update_service.dart';
import 'package:dear_flutter/services/music_update_service.dart';
import 'package:audio_service/audio_service.dart';
import 'services/audio_player_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Inisialisasi dependency injection (getIt, dll.)
  await configureDependencies();
  final handler = await AudioService.init(
    builder: () => getIt<AudioPlayerHandler>(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.dear.audio',
      androidNotificationChannelName: 'Audio Playback',
    ),
  );
  if (!getIt.isRegistered<AudioPlayerHandler>()) {
    getIt.registerSingleton<AudioPlayerHandler>(handler);
  }
  await getIt<NotificationService>().init();
  getIt<QuoteUpdateService>().start();
  getIt<MusicUpdateService>().start();

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
