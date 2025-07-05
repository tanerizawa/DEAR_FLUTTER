// test/helpers/test_helper.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/repositories/home_repository.dart';
import 'package:dear_flutter/domain/repositories/journal_repository.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Import the generated mock file
import 'test_helper.mocks.dart';

// Annotation to generate all the mock classes we need
@GenerateMocks([
  HomeRepository,
  JournalRepository,
  SongHistoryRepository,
  AudioPlayerHandler,
  HomeFeedCubit,
])
void setupTestDependencies() {
  // Clear all previous registrations
  GetIt.instance.reset();

  // Create mock instances
  final mockHomeRepo = MockHomeRepository();
  final mockJournalRepo = MockJournalRepository();
  final mockSongHistoryRepo = MockSongHistoryRepository();
  final mockAudioHandler = MockAudioPlayerHandler();

  // Register the mock instances with GetIt
  getIt.registerSingleton<HomeRepository>(mockHomeRepo);
  getIt.registerSingleton<JournalRepository>(mockJournalRepo);
  getIt.registerSingleton<SongHistoryRepository>(mockSongHistoryRepo);
  getIt.registerSingleton<AudioPlayerHandler>(mockAudioHandler);
}