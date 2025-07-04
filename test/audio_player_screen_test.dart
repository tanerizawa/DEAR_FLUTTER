// test/audio_player_screen_test.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:dear_flutter/presentation/home/screens/audio_player_screen.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

import 'audio_player_screen_test.mocks.dart';

@GenerateMocks([AudioPlayerHandler, SongHistoryRepository])
void main() {
  late MockAudioPlayerHandler mockAudioHandler;
  late MockSongHistoryRepository mockSongHistoryRepo;

  final testTrack = AudioTrack(
    id: 1,
    title: 'Lagu Tes',
    artist: 'Artis Tes',
    youtubeId: 'xyz123',
  );

  setUp(() {
    mockAudioHandler = MockAudioPlayerHandler();
    mockSongHistoryRepo = MockSongHistoryRepository();

    GetIt.instance.reset();

    getIt.registerSingleton<AudioPlayerHandler>(mockAudioHandler);
    getIt.registerSingleton<SongHistoryRepository>(mockSongHistoryRepo);

    // --- PERBAIKAN UTAMA: Gunakan BehaviorSubject untuk mock stream ---
    final playbackStateSubject = BehaviorSubject<PlaybackState>.seeded(PlaybackState());
    when(mockAudioHandler.playbackState).thenAnswer((_) => playbackStateSubject);

    final mediaItemSubject = BehaviorSubject<MediaItem?>.seeded(null);
    when(mockAudioHandler.mediaItem).thenAnswer((_) => mediaItemSubject);
  });

  Future<void> pumpAudioPlayerScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AudioPlayerScreen(track: testTrack),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('AudioPlayerScreen should display track title and artist', (WidgetTester tester) async {
    await pumpAudioPlayerScreen(tester);

    expect(find.text('Lagu Tes'), findsOneWidget);
    expect(find.text('Artis Tes'), findsOneWidget);
  });

  testWidgets('tapping play button calls the correct handler methods', (WidgetTester tester) async {
    when(mockSongHistoryRepo.addTrack(any)).thenAnswer((_) async {});
    when(mockAudioHandler.playFromYoutubeId(any, any)).thenAnswer((_) async {});

    await pumpAudioPlayerScreen(tester);

    final playButton = find.byIcon(Icons.play_circle_filled);
    expect(playButton, findsOneWidget);
    await tester.tap(playButton);
    await tester.pump();

    verify(mockSongHistoryRepo.addTrack(testTrack)).called(1);
    verify(mockAudioHandler.playFromYoutubeId(testTrack.youtubeId, testTrack)).called(1);
  });

  testWidgets('tapping pause button calls handler.pause', (WidgetTester tester) async {
    final playingStateSubject = BehaviorSubject<PlaybackState>.seeded(PlaybackState(playing: true));
    when(mockAudioHandler.playbackState).thenAnswer((_) => playingStateSubject);
    when(mockAudioHandler.pause()).thenAnswer((_) async {});

    await pumpAudioPlayerScreen(tester);

    final pauseButton = find.byIcon(Icons.pause_circle_filled);
    expect(pauseButton, findsOneWidget);
    await tester.tap(pauseButton);
    await tester.pump();

    verify(mockAudioHandler.pause()).called(1);
  });
}