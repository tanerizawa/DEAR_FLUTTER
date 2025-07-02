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
    when(() => search.searchId(any())).thenAnswer((_) async => 'id');
    getIt.registerSingleton<YoutubeSearchService>(search);
  });

  tearDown(getIt.reset);

  testWidgets('HomeScreen renders music card', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('t'), findsOneWidget);
  });

  testWidgets('tapping music card resolves id and navigates',
      (WidgetTester tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/audio',
        builder: (_, state) {
          final track = state.extra as AudioTrack;
          return Text(track.youtubeId);
        },
      ),
    ]);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('t'));
    await tester.pumpAndSettle();

    expect(find.text('id'), findsOneWidget);
  });

}
