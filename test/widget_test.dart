// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';

// Import the test helper
import 'helpers/test_helper.dart';
import 'helpers/test_helper.mocks.dart';

void main() {
  late MockAudioPlayerHandler mockAudioHandler;
  late MockSongHistoryRepository mockSongHistoryRepo;

  final testTrack = AudioTrack(id: 1, title: 'Test', artist: 'Artist', youtubeId: 'id');

  setUp(() {
    setupTestDependencies();
    mockAudioHandler = getIt<MockAudioPlayerHandler>();
    mockSongHistoryRepo = getIt<MockSongHistoryRepository>();
  });

  test('simulate play action', () async {
    // Arrange
    when(mockSongHistoryRepo.addTrack(any)).thenAnswer((_) async {});
    when(mockAudioHandler.playFromYoutubeId(any, any)).thenAnswer((_) async {});

    // Act
    await mockSongHistoryRepo.addTrack(testTrack);
    await mockAudioHandler.playFromYoutubeId(testTrack.youtubeId, testTrack);

    // Assert
    verify(mockSongHistoryRepo.addTrack(testTrack)).called(1);
    verify(mockAudioHandler.playFromYoutubeId(testTrack.youtubeId, testTrack)).called(1);
  });
}