import 'package:dear_flutter/domain/entities/audio_track.dart';

abstract class SongHistoryRepository {
  Future<void> addTrack(AudioTrack track);
  List<AudioTrack> getHistory();
  /// Ambil history lagu yang diputar hari ini (reset jam 00.00)
  List<AudioTrack> getHistoryToday();
}
