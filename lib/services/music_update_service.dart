import 'dart:async';

import 'package:dear_flutter/data/datasources/remote/home_api_service.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:injectable/injectable.dart';
import 'package:dear_flutter/domain/repositories/song_suggestion_cache_repository.dart';

@LazySingleton()
class MusicUpdateService {
  final HomeApiService _apiService;
  final SongSuggestionCacheRepository _cacheRepository;

  Timer? _timer;
  List<SongSuggestion> _latest = const [];

  MusicUpdateService(this._apiService, this._cacheRepository);

  void start() {
    _timer?.cancel();
    _fetch();
    _timer = Timer.periodic(const Duration(minutes: 15), (_) => _fetch());
  }

  List<SongSuggestion> get latest =>
      _latest.isNotEmpty ? _latest : _cacheRepository.getLastSuggestions();

  Future<void> _fetch() async {
    try {
      final suggestions = await _apiService.getSuggestedMusic('Netral');
      _latest = suggestions;
      await _cacheRepository.saveSuggestions(suggestions);
    } catch (_) {
      // ignore errors
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
