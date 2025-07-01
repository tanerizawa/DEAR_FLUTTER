import 'dart:async';

import 'package:dear_flutter/data/datasources/remote/home_api_service.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class MusicUpdateService {
  final HomeApiService _apiService;

  Timer? _timer;
  List<SongSuggestion> _latest = const [];

  MusicUpdateService(this._apiService);

  void start() {
    _timer?.cancel();
    _fetch();
    _timer = Timer.periodic(const Duration(minutes: 15), (_) => _fetch());
  }

  List<SongSuggestion> get latest => _latest;

  Future<void> _fetch() async {
    try {
      final suggestions = await _apiService.getSuggestedMusic();
      _latest = suggestions;
    } catch (_) {
      // ignore errors
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
