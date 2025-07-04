// lib/data/repositories/home_repository_impl.dart

import 'package:dear_flutter/data/datasources/remote/home_api_service.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/home_feed.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:dear_flutter/domain/repositories/home_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementasi dari `HomeRepository` yang mengambil data dari `HomeApiService`.
@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeApiService _apiService;

  HomeRepositoryImpl(this._apiService);

  @override
  Future<HomeFeed> getHomeFeed() {
    // Cukup teruskan panggilan langsung ke service.
    // Error handling akan ditangani di lapisan atas (misal: Cubit).
    return _apiService.getHomeFeed();
  }

  @override
  Future<AudioTrack?> getLatestMusic() {
    return _apiService.getLatestMusic();
  }

  @override
  Future<MotivationalQuote> getLatestQuote() {
    return _apiService.getLatestQuote();
  }

  @override
  Future<List<SongSuggestion>> getMusicSuggestions(String mood) {
    return _apiService.getSuggestedMusic(mood);
  }

  @override
  Future<List<AudioTrack>> getRadioStation(String category) {
    return _apiService.getRadioStation(category);
  }

  @override
  Future<void> triggerMusicGeneration() async {
    // Untuk fungsi 'fire-and-forget', kita bisa menangani error di sini
    // agar tidak menghentikan alur aplikasi utama.
    try {
      await _apiService.triggerMusicGeneration();
    } catch (e, s) {
      debugPrint('[HomeRepository] Gagal memicu generasi musik: $e');
      debugPrintStack(stackTrace: s);
      // Tidak melempar error lagi (re-throw) karena ini bukan operasi kritis.
    }
  }

  @override
  Future<void> triggerQuoteGeneration() async {
    try {
      await _apiService.triggerQuoteGeneration();
    } catch (e, s) {
      debugPrint('[HomeRepository] Gagal memicu generasi kutipan: $e');
      debugPrintStack(stackTrace: s);
      // Tidak melempar error lagi (re-throw).
    }
  }
}