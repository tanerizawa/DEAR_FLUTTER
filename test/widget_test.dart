import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dear_flutter/presentation/home/screens/home_screen.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:dear_flutter/services/youtube_search_service.dart';
import 'package:go_router/go_router.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:mocktail/mocktail.dart';

const _sampleSuggestion = SongSuggestion(title: 't', artist: 'a');

class _FakeLatestMusicCubit extends Cubit<LatestMusicState>
    implements LatestMusicCubit {
  _FakeLatestMusicCubit()
      : super(const LatestMusicState(
          status: LatestMusicStatus.success,
          suggestions: [_sampleSuggestion],
        ));

  @override
  Future<void> fetchLatestMusic() async {}
}

class _MockSearchService extends Mock implements YoutubeSearchService {}
class _MockHandler extends Mock implements AudioPlayerHandler {}
class _FakeSongHistoryRepository implements SongHistoryRepository {
  @override
  Future<void> addTrack(AudioTrack track) async {}

  @override
  List<AudioTrack> getHistory() => [];
}

class _FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(_FakeRoute());
  });

  setUp(() {
    getIt.reset();
    getIt.registerFactory<LatestMusicCubit>(() => _FakeLatestMusicCubit());
    final search = _MockSearchService();
    when(() => search.search(any())).thenAnswer(
      (_) async => YoutubeSearchResult('id', 'thumb'),
    );
    getIt.registerSingleton<YoutubeSearchService>(search);
  });

  tearDown(getIt.reset);

  testWidgets('HomeScreen renders music card', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('t'), findsOneWidget);
  });

  testWidgets('tapping music card resolves id and plays',
      (WidgetTester tester) async {
    final handler = _MockHandler();
    when(() => handler.playbackState).thenAnswer((_) => const Stream.empty());
    when(() => handler.playFromYoutubeId(any())).thenAnswer((_) async {});
    getIt.registerSingleton<AudioPlayerHandler>(handler);
    getIt.registerSingleton<SongHistoryRepository>(
        _FakeSongHistoryRepository());

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.text('t'));
    await tester.pump();

    verify(() => handler.playFromYoutubeId('id')).called(1);
  });

}
