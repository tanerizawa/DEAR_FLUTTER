import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/repositories/latest_music_cache_repository.dart';

@LazySingleton(as: LatestMusicCacheRepository)
class LatestMusicCacheRepositoryImpl implements LatestMusicCacheRepository {
  final Box<Map> _box;

  LatestMusicCacheRepositoryImpl(@Named('latestMusicBox') this._box);

  @override
  Future<void> saveTrack(AudioTrack track) =>
      _box.put('latest', track.toJson());

  @override
  AudioTrack? getLastTrack() {
    final data = _box.get('latest');
    if (data == null) return null;
    return AudioTrack.fromJson(Map<String, dynamic>.from(data));
  }
}
