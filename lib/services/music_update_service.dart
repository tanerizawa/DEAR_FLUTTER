import 'dart:async';

import 'package:dear_flutter/data/datasources/remote/home_api_service.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/repositories/latest_music_cache_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class MusicUpdateService {
  final HomeApiService _apiService;
  final LatestMusicCacheRepository _cacheRepository;

  Timer? _timer;
  AudioTrack? _latest;
  bool _initialFetchDone = false;
  MusicUpdateService(this._apiService, this._cacheRepository);

  void start() {
    _timer?.cancel();
    _initialFetchDone = false;
    _fetch().whenComplete(() => _initialFetchDone = true);
    _timer = Timer.periodic(const Duration(minutes: 15), (_) => _fetch());
  }

  Future<AudioTrack?> refresh() => _fetch();

  AudioTrack? get latest => _latest ?? _cacheRepository.getLastTrack();

  bool get hasFetchedInitial => _initialFetchDone;

  Future<AudioTrack?> _fetch() async {
    try {
      final track = await _apiService.getLatestMusic();
      if (track != null) {
        _latest = track;
        await _cacheRepository.saveTrack(track);
      }
      return _latest;
    } catch (_) {
      return _cacheRepository.getLastTrack();
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
