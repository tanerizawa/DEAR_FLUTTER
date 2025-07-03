
import 'package:audio_service/audio_service.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_state.dart';
import 'package:dear_flutter/presentation/home/screens/home_screen.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

class _FakeMusicCubit extends Cubit<LatestMusicState>
    implements LatestMusicCubit {
  _FakeMusicCubit()
      : super(const LatestMusicState(
          status: LatestMusicStatus.success,
          track: AudioTrack(id: 1, title: 't', youtubeId: 'id', artist: 'a'),
        ));

  @override
  Future<void> fetchLatestMusic() async {}
}

class _FakeQuoteCubit extends Cubit<LatestQuoteState>
    implements LatestQuoteCubit {
  _FakeQuoteCubit()
      : super(const LatestQuoteState(
          status: LatestQuoteStatus.cached,
          quote: MotivationalQuote(id: 1, text: 'q', author: 'a'),
        ));

  @override
  Future<void> fetchLatestQuote() async {}
}


class _MockHandler extends Mock implements AudioPlayerHandler {}

class _MockSongHistoryRepo extends Mock implements SongHistoryRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final getIt = GetIt.instance;

  setUp(() {
    getIt.reset();
    getIt.registerFactory<LatestMusicCubit>(() => _FakeMusicCubit());
    getIt.registerFactory<LatestQuoteCubit>(() => _FakeQuoteCubit());
  });

  tearDown(getIt.reset);

  testWidgets('tapping music card plays and shows player bar',
      (WidgetTester tester) async {

    final handler = _MockHandler();
    final controller = BehaviorSubject<PlaybackState>();
    controller.add(
      PlaybackState(
        playing: false,
        processingState: AudioProcessingState.ready,
        controls: <MediaControl>[],
      ),
    );
    when(() => handler.playbackState).thenAnswer((_) => controller);
    when(() => handler.playFromYoutubeId(any())).thenAnswer((_) async {
      controller.add(PlaybackState(
        playing: true,
        processingState: AudioProcessingState.ready,
        controls: <MediaControl>[],
      ));
    });
    getIt.registerSingleton<AudioPlayerHandler>(handler);

    final repo = _MockSongHistoryRepo();
    when(() => repo.addTrack(any())).thenAnswer((_) async {});
    when(repo.getHistory).thenReturn([]);
    getIt.registerSingleton<SongHistoryRepository>(repo);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.text('t'));
    await tester.pump();

    verify(() => handler.playFromYoutubeId('id')).called(1);

    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('t'), findsNWidgets(2));
    expect(find.byIcon(Icons.pause), findsOneWidget);

    controller.add(PlaybackState(
      playing: false,
      processingState: AudioProcessingState.ready,
      controls: <MediaControl>[],
    ));
    await tester.pump();

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
