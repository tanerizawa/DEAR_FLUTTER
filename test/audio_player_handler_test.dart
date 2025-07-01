import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/services/youtube_audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';

class _MockAudioPlayer extends Mock implements AudioPlayer {}
class _MockYoutubeService extends Mock implements YoutubeAudioService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    registerFallbackValue(PlayerState(false, ProcessingState.idle));
  });

  test('playFromYoutubeId resolves url and plays', () async {
    final player = _MockAudioPlayer();
    final yt = _MockYoutubeService();
    final controller = StreamController<PlayerState>();

    when(() => yt.getAudioUrl('id')).thenAnswer((_) async => 'u');
    when(() => player.playerStateStream).thenAnswer((_) => controller.stream);
    when(() => player.setUrl('u')).thenAnswer((_) async {});
    when(player.play).thenAnswer((_) async {});

    final handler = AudioPlayerHandler(yt, player: player);
    controller.add(PlayerState(false, ProcessingState.ready));

    await handler.playFromYoutubeId('id');

    verify(() => player.setUrl('u')).called(1);
    verify(player.play).called(1);
  });

  test('playbackState reflects player state', () async {
    final player = _MockAudioPlayer();
    final yt = _MockYoutubeService();
    final controller = StreamController<PlayerState>();

    when(() => player.playerStateStream).thenAnswer((_) => controller.stream);
    final handler = AudioPlayerHandler(yt, player: player);

    final future = handler.playbackState.first;
    controller.add(PlayerState(true, ProcessingState.ready));

    final state = await future;
    expect(state.playing, isTrue);
  });

  test('stop disposes player and closes youtube', () async {
    final player = _MockAudioPlayer();
    final yt = _MockYoutubeService();

    when(player.dispose).thenAnswer((_) async {});
    when(() => yt.close()).thenReturn(null);

    final handler = AudioPlayerHandler(yt, player: player);

    await handler.stop();

    verify(player.dispose).called(1);
    verify(() => yt.close()).called(1);
  });
}
