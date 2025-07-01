// lib/core/di/injection.dart

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/services/youtube_audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'injection.config.dart'; // File ini akan dibuat oleh generator

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<GetIt> configureDependencies() async {
  await getIt.init();
  // Manual registrations not covered by code generation
  if (!getIt.isRegistered<AudioPlayerHandler>()) {
    getIt.registerLazySingleton<AudioPlayerHandler>(
      () => AudioPlayerHandler(
        getIt<YoutubeAudioService>(),
        player: getIt<AudioPlayer>(),
      ),
    );
  }
  return getIt;
}
