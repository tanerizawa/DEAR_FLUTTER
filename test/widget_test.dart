import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dear_flutter/presentation/home/screens/home_screen.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';

const _sampleTrack =
    AudioTrack(id: 1, title: 't', youtubeId: 'id', artist: 'a');

class _FakeLatestMusicCubit extends Cubit<LatestMusicState>
    implements LatestMusicCubit {
  _FakeLatestMusicCubit()
      : super(const LatestMusicState(
          status: LatestMusicStatus.success,
          track: _sampleTrack,
        ));

  @override
  Future<void> fetchLatestMusic() async {}
}

class _MockHandler extends Mock implements AudioPlayerHandler {}
class _MockSongHistoryRepository extends Mock implements SongHistoryRepository {}

void main() {
  final getIt = GetIt.instance;
  late _MockHandler handler;

  setUpAll(() {});

  setUp(() {
    getIt.reset();
    getIt.registerFactory<LatestMusicCubit>(() => _FakeLatestMusicCubit());
    handler = _MockHandler();
    getIt.registerSingleton<AudioPlayerHandler>(handler);
    getIt.registerSingleton<SongHistoryRepository>(_MockSongHistoryRepository());
  });

  tearDown(getIt.reset);

  testWidgets('HomeScreen renders music card', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('t'), findsOneWidget);
  });

  testWidgets('tapping music card resolves id and plays',
      (WidgetTester tester) async {
    when(() => handler.playbackState).thenAnswer(
      (_) => BehaviorSubject.seeded(
        PlaybackState(
          processingState: AudioProcessingState.idle,
          playing: false,
          controls: const <MediaControl>[],
        ),
      ),
    );
    when(() => handler.playFromYoutubeId(any())).thenAnswer((_) async {});

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.text('t'));
    await tester.pump();

    verify(() => handler.playFromYoutubeId('id')).called(1);
    expect(find.text('Playing...'), findsOneWidget); // Add status feedback
  });
}
