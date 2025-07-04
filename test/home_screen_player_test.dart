// test/home_screen_player_test.dart

import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/home_feed.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:dear_flutter/presentation/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

// Import the test helper
import '../helpers/test_helper.dart';
import '../helpers/test_helper.mocks.dart';

void main() {
  late MockHomeFeedCubit mockHomeFeedCubit;
  late MockAudioPlayerHandler mockAudioHandler;
  late MockSongHistoryRepository mockSongHistoryRepo;

  final testTrack = AudioTrack(id: 1, title: 'Test Song', artist: 'Artist', youtubeId: '123');

  setUp(() {
    // Call the setup function from the helper
    setupTestDependencies();
    mockHomeFeedCubit = MockHomeFeedCubit();
    mockAudioHandler = getIt<MockAudioPlayerHandler>();
    mockSongHistoryRepo = getIt<MockSongHistoryRepository>();
  });

  Future<void> pumpHomeScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<HomeFeedCubit>(
        create: (context) => mockHomeFeedCubit,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Tapping play button calls playFromYoutubeId', (tester) async {
    // Arrange
    when(mockHomeFeedCubit.state).thenReturn(HomeFeedState(
      status: HomeFeedStatus.success,
      feed: HomeFeed(music: testTrack, quote: null),
    ));
    when(mockHomeFeedCubit.stream).thenAnswer((_) => Stream.value(mockHomeFeedCubit.state));
    when(mockSongHistoryRepo.addTrack(any)).thenAnswer((_) async {});
    when(mockAudioHandler.playFromYoutubeId(any, any)).thenAnswer((_) async {});
    when(mockAudioHandler.playbackState).thenAnswer((_) => Stream.value(PlaybackState()));
    when(mockAudioHandler.mediaItem).thenAnswer((_) => BehaviorSubject.seeded(null));

    // Act
    await pumpHomeScreen(tester);
    
    final playButton = find.byIcon(Icons.play_circle_filled_rounded);
    expect(playButton, findsOneWidget, reason: "Play button should be on screen");
    
    await tester.tap(playButton);
    await tester.pump();

    // Assert
    verify(mockSongHistoryRepo.addTrack(testTrack)).called(1);
    verify(mockAudioHandler.playFromYoutubeId(testTrack.youtubeId, testTrack)).called(1);
  });
}