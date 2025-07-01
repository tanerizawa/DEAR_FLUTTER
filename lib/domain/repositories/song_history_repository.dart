import 'package:dear_flutter/domain/entities/audio_track.dart';

abstract class SongHistoryRepository {
  Future<void> addTrack(AudioTrack track);
  List<AudioTrack> getHistory();
}
