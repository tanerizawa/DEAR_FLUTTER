import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:dear_flutter/presentation/home/screens/audio_player_screen.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/services/youtube_audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';

class _MockYoutubeService extends Mock implements YoutubeAudioService {}

class _MockAudioPlayer extends Mock implements AudioPlayer {}

class _FakeSongHistoryRepository implements SongHistoryRepository {
  @override
  Future<void> addTrack(AudioTrack track) async {}

  @override
  List<AudioTrack> getHistory() => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final getIt = GetIt.instance;

  setUp(() {
    getIt.reset();
    registerFallbackValue(PlayerState(false, ProcessingState.idle));
  });

  tearDown(getIt.reset);

  testWidgets('tapping play toggles icon and resolves url',
      (WidgetTester tester) async {
    final yt = _MockYoutubeService();
    final player = _MockAudioPlayer();
    final repo = _FakeSongHistoryRepository();
    final controller = StreamController<PlayerState>();

    when(() => yt.getAudioUrl('id')).thenAnswer((_) async => 'u');
    when(() => player.playerStateStream).thenAnswer((_) => controller.stream);
    when(() => player.setUrl('u')).thenAnswer((_) async {});
    when(player.play).thenAnswer((_) async {
      controller.add(PlayerState(true, ProcessingState.ready));
    });
    when(player.pause).thenAnswer((_) async {
      controller.add(PlayerState(false, ProcessingState.ready));
    });

    final handler = AudioPlayerHandler(yt, player: player);
    controller.add(PlayerState(false, ProcessingState.ready));

    getIt.registerSingleton<AudioPlayerHandler>(handler);
    getIt.registerSingleton<SongHistoryRepository>(repo);

    const track = AudioTrack(id: 1, title: 't', youtubeId: 'id');

    await tester.pumpWidget(const MaterialApp(home: AudioPlayerScreen(track: track)));

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(find.byIcon(Icons.pause), findsOneWidget);
    verify(() => yt.getAudioUrl('id')).called(1);

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
