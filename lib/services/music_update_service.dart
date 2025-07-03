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
    _timer = Timer.periodic(const Duration(minutes: 15), (_) => _fetch());
  }

  Future<AudioTrack?> refresh() => _fetch();

  AudioTrack? get latest => _latest;

  Future<AudioTrack?> _fetch() async {
    try {
      _latest = await _apiService.getLatestMusic();
      return _latest;
    } catch (_) {
      // ignore errors
      return null;
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
