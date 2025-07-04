import 'package:hive/hive.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';

class AudioMetadataCacheService {
  static const String boxName = 'audio_metadata';

  Future<void> saveMetadata(AudioTrack track, String audioUrl, Duration? duration) async {
    final box = await Hive.openBox(boxName);
    final data = {
      'id': track.id,
      'title': track.title,
      'artist': track.artist,
      'youtubeId': track.youtubeId,
      'coverUrl': track.coverUrl,
      'audioUrl': audioUrl,
      'duration': duration?.inMilliseconds,
    };
    await box.put(track.youtubeId, data);
  }

  Future<Map<String, dynamic>?> getMetadata(String youtubeId) async {
    final box = await Hive.openBox(boxName);
    final raw = box.get(youtubeId);
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  Future<void> clear() async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }
}
