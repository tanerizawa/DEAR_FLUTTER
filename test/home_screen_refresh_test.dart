import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_state.dart';
import 'package:dear_flutter/presentation/home/screens/home_screen.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';

class _TestMusicCubit extends Mock implements LatestMusicCubit {}
class _TestQuoteCubit extends Mock implements LatestQuoteCubit {}
class _DummyHandler extends Mock implements AudioPlayerHandler {}
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
    final musicCubit = _TestMusicCubit();
    when(() => musicCubit.state).thenReturn(const LatestMusicState(
      status: LatestMusicStatus.cached,
      track: AudioTrack(id: 1, title: 't', youtubeId: 'y', artist: 'a'),
    ));
    when(() => musicCubit.fetchLatestMusic()).thenAnswer((_) async {});

    final quoteCubit = _TestQuoteCubit();
    when(() => quoteCubit.state).thenReturn(const LatestQuoteState(
      status: LatestQuoteStatus.cached,
      quote: MotivationalQuote(id: 1, text: 'q', author: 'a'),
    ));
    when(() => quoteCubit.fetchLatestQuote()).thenAnswer((_) async {});

    getIt.registerFactory<LatestMusicCubit>(() => musicCubit);
    getIt.registerFactory<LatestQuoteCubit>(() => quoteCubit);
    getIt.registerSingleton<AudioPlayerHandler>(_DummyHandler());
    getIt.registerSingleton<SongHistoryRepository>(_FakeSongHistoryRepository());
  });

  tearDown(getIt.reset);

  testWidgets('pull to refresh does not throw provider error',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(tester.takeException(), isNull);

    // Trigger refresh
    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });
}
