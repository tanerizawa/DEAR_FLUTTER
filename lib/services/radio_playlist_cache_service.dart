import 'package:hive/hive.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';

class RadioPlaylistCacheService {
  Future<void> savePlaylist(String category, List<AudioTrack> playlist) async {
    final box = await Hive.openBox('radio_playlist_$category');
    final data = playlist.map((t) => t.toJson()).toList();
    await box.put('playlist', data);
  }

  Future<List<AudioTrack>> getPlaylist(String category) async {
    final box = await Hive.openBox('radio_playlist_$category');
    final data = box.get('playlist') as List?;
    if (data == null) return [];
    return data.map((e) => AudioTrack.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> clear(String category) async {
    final box = await Hive.openBox('radio_playlist_$category');
    await box.clear();
  }
}
