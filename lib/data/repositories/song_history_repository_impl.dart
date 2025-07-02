import 'package:injectable/injectable.dart';
import 'package:hive/hive.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';

@LazySingleton(as: SongHistoryRepository)
class SongHistoryRepositoryImpl implements SongHistoryRepository {
  final Box<Map> _box;

  SongHistoryRepositoryImpl(@Named('songBox') this._box);

  @override
  Future<void> addTrack(AudioTrack track) => _box.add(track.toJson());

  @override
  List<AudioTrack> getHistory() => _box.values
      .map((e) => AudioTrack.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}
