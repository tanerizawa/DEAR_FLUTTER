import 'dart:async';

import 'package:dear_flutter/data/datasources/remote/home_api_service.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class MusicUpdateService {
  final HomeApiService _apiService;

  Timer? _timer;
  AudioTrack? _latest;

  MusicUpdateService(this._apiService);

  void start() {
    _timer?.cancel();
    _fetch();
    _timer = Timer.periodic(const Duration(minutes: 10), (_) => _fetch());
  }

  AudioTrack? get latest => _latest;

  Future<void> _fetch() async {
    try {
      final track = await _apiService.getLatestMusic();
      _latest = track;
    } catch (_) {
      // ignore errors
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
