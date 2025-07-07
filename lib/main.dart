import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/core/navigation/app_router.dart';
import 'package:dear_flutter/core/theme/unified_theme_system.dart';
import 'package:dear_flutter/core/theme/personalized_theme_engine.dart';
import 'package:dear_flutter/services/notification_service.dart';
import 'package:dear_flutter/services/quote_update_service.dart';
import 'package:dear_flutter/services/music_update_service.dart';
import 'package:audio_service/audio_service.dart';
import 'services/audio_player_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  
  // Initialize advanced theme systems (Phase 2 & 3)
  await UnifiedThemeSystem.initializeAdvancedSystems();

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

  runApp(const MyApp());

  // Delay starting services until after the first frame to prevent skipped-frame warnings
  WidgetsBinding.instance.addPostFrameCallback((_) {
    getIt<QuoteUpdateService>().start(immediateFetch: false);
    getIt<MusicUpdateService>().start(immediateFetch: false);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Dispose advanced theme systems
    UnifiedThemeSystem.disposeAdvancedSystems();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Record system theme change interaction
    UnifiedThemeSystem.recordThemeInteraction(
      type: InteractionType.brightnessToogle,
      context: {
        'platformBrightness': WidgetsBinding.instance.platformDispatcher.platformBrightness.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return FutureBuilder<ThemeData>(
            // Use intelligent theme generation for enhanced experience
            future: UnifiedThemeSystem.generateIntelligentTheme(
              mood: themeProvider.currentMood,
              isDark: themeProvider.isDarkMode,
              contrast: themeProvider.contrastLevel,
              textScaleFactor: themeProvider.textScaleFactor,
              context: {
                'screenSize': MediaQuery.of(context).size.toString(),
                'platform': Theme.of(context).platform.toString(),
                'timestamp': DateTime.now().toIso8601String(),
              },
            ),
            builder: (context, snapshot) {
              final theme = snapshot.data ?? UnifiedThemeSystem.generateTheme(
                mood: themeProvider.currentMood,
                isDark: themeProvider.isDarkMode,
                contrast: themeProvider.contrastLevel,
                textScaleFactor: themeProvider.textScaleFactor,
              );

              return MaterialApp.router(
                routerConfig: router,
                debugShowCheckedModeBanner: false,
                title: 'Dear App',
                
                // Use intelligent theme with fallback
                theme: theme,
                
                // Dark theme dengan intelligent adaptation
                darkTheme: theme,
                
                // Smart theme mode detection
                themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                
                // Enhanced material app configuration
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(themeProvider.textScaleFactor),
                    ),
                    child: child!,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
