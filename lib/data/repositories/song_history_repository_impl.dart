import 'package:injectable/injectable.dart';
import 'package:hive/hive.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';

@LazySingleton(as: SongHistoryRepository)
class SongHistoryRepositoryImpl implements SongHistoryRepository {
  final Box<Map> _box;

  SongHistoryRepositoryImpl(@Named('songBox') this._box);

  @override
  Future<void> addTrack(AudioTrack track) async {
    final now = DateTime.now();
    await _box.add({
      ...track.toJson(),
      'playedAt': now.toIso8601String(),
    });
  }

  /// Ambil semua history (tanpa filter waktu)
  @override
  List<AudioTrack> getHistory() => _box.values
      .map((e) => AudioTrack.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  /// Ambil history lagu yang diputar hari ini (reset jam 00.00)
  List<Map<String, dynamic>> getHistoryTodayRaw() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _box.values
        .where((e) {
          final playedAt = DateTime.tryParse(e['playedAt'] ?? '') ?? DateTime(2000);
          return playedAt.isAfter(today);
        })
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Ambil list AudioTrack yang diputar hari ini
  List<AudioTrack> getHistoryToday() {
    return getHistoryTodayRaw().map((e) => AudioTrack.fromJson(e)).toList();
  }
}
