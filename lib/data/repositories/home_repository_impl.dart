// lib/data/repositories/home_repository_impl.dart

import 'package:injectable/injectable.dart';
import 'package:dear_flutter/data/datasources/remote/home_api_service.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:dear_flutter/domain/entities/home_feed.dart';
import 'package:dear_flutter/domain/repositories/home_repository.dart';
import 'package:flutter/foundation.dart'; // Import untuk debugPrint

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeApiService _apiService;

  HomeRepositoryImpl(this._apiService);

  @override
  Future<HomeFeed> getHomeFeed() {
    return _apiService.getHomeFeed();
  }

  @override
  Future<MotivationalQuote> getLatestQuote() {
    return _apiService.getLatestQuote();
  }

  @override
  Future<AudioTrack?> getLatestMusic() {
    return _apiService.getLatestMusic();
  }

  @override
  Future<List<SongSuggestion>> getMusicSuggestions(String mood) {
    return _apiService.getSuggestedMusic(mood);
  }

  @override
  Future<void> triggerMusicGeneration() async {
    try {
      // --- PERBAIKAN: Gunakan _apiService ---
      await _apiService.triggerMusicGeneration();
    } catch (e) {
      debugPrint('Gagal memicu generasi musik: $e');
    }
  }

  @override
  Future<void> triggerQuoteGeneration() async {
    try {
      // --- PERBAIKAN: Gunakan _apiService ---
      await _apiService.triggerQuoteGeneration();
    } catch (e) {
      debugPrint('Gagal memicu generasi kutipan: $e');
    }
  }
}