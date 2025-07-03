import 'package:dear_flutter/services/music_update_service.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMusicUpdateService extends Mock implements MusicUpdateService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const track = AudioTrack(
    id: 1,
    title: 't',
    youtubeId: 'y',
    artist: 'a',
  );

  test('loads cached track on init', () async {
    final service = _MockMusicUpdateService();
    when(() => service.latest).thenReturn(track);
    final cubit = LatestMusicCubit(service);

    expect(cubit.state.status, LatestMusicStatus.cached);
    expect(cubit.state.track, track);
  });

  test('fetchLatestMusic retrieves track from service', () async {
    final service = _MockMusicUpdateService();
    when(() => service.latest).thenReturn(null);
    when(service.refresh).thenAnswer((_) async => track);

    final cubit = LatestMusicCubit(service);
    await cubit.fetchLatestMusic();

    expect(cubit.state.status, LatestMusicStatus.success);
    expect(cubit.state.track, track);
    verify(service.refresh).called(1);
  });
}
