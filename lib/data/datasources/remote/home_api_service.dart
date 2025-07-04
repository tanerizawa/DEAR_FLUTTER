// lib/data/datasources/remote/home_api_service.dart

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:dear_flutter/domain/entities/home_feed.dart';

@injectable
class HomeApiService {
  final Dio _dio;
  HomeApiService(this._dio);

  Future<MotivationalQuote> getLatestQuote() async {
    final response = await _dio.get('quotes/latest');
    return MotivationalQuote.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<AudioTrack?> getLatestMusic() async {
    final response = await _dio.get('music/latest');
    final data = response.data;
    if (data == null) return null;
    return AudioTrack.fromJson(data as Map<String, dynamic>);
  }

  Future<List<SongSuggestion>> getSuggestedMusic(String mood) async {
    final response = await _dio.get(
      'music/recommend',
      queryParameters: {'mood': mood},
    );
    final data = response.data as List<dynamic>;
    return data
        .map((e) => SongSuggestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<HomeFeed> getHomeFeed() async {
    final response = await _dio.get('home-feed');
    return HomeFeed.fromJson(response.data as Map<String, dynamic>);
  }

  // --- REVISI UTAMA: MENAMBAHKAN DUA METODE BARU DI SINI ---

  /// Memicu proses generasi musik baru di backend.
  Future<void> triggerMusicGeneration() async {
    // Melakukan panggilan POST ke endpoint yang sesuai.
    // Kita tidak perlu menunggu atau memproses responsnya (fire and forget).
    await _dio.post('music/trigger-generation');
  }

  /// Memicu proses generasi kutipan baru di backend.
  Future<void> triggerQuoteGeneration() async {
    // Melakukan panggilan POST ke endpoint yang sesuai.
    await _dio.post('quotes/trigger-generation');
  }
}