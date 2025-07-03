import 'package:dear_flutter/domain/entities/audio_track.dart';

abstract class LatestMusicCacheRepository {
  Future<void> saveTrack(AudioTrack track);
  AudioTrack? getLastTrack();
}
