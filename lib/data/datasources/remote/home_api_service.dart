// lib/data/datasources/remote/home_api_service.dart

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:dear_flutter/domain/entities/home_feed.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';

/// Service class for handling all home-related API calls.
@injectable
class HomeApiService {
  final Dio _dio;
  HomeApiService(this._dio);

  /// Fetches the entire home feed in a single call.
  Future<HomeFeed> getHomeFeed() async {
    final response = await _dio.get('home-feed');
    return HomeFeed.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetches the latest motivational quote.
  Future<MotivationalQuote> getLatestQuote() async {
    final response = await _dio.get('quotes/latest');
    return MotivationalQuote.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetches the latest generated music track. Can be null.
  Future<AudioTrack?> getLatestMusic() async {
    final response = await _dio.get('music/latest');
    final data = response.data;
    print('[DEBUG] Response music/latest:');
    print(data);
    if (data == null) {
      return null;
    }
    return AudioTrack.fromJson(data as Map<String, dynamic>);
  }

  /// Fetches a list of song suggestions based on a mood.
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
  
  /// Fetches a list of audio tracks for a specific radio station category.
  Future<List<AudioTrack>> getRadioStation(String category) async {
    final response = await _dio.get(
      'music/station',
      queryParameters: {'category': category},
    );
    final data = response.data as List<dynamic>;
    return data
        .map((e) => AudioTrack.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Triggers a new music generation process on the backend.
  Future<void> triggerMusicGeneration() async {
    // This is a 'fire and forget' call, we don't need the response.
    await _dio.post('music/trigger-generation');
  }

  /// Triggers a new quote generation process on the backend.
  Future<void> triggerQuoteGeneration() async {
    await _dio.post('quotes/trigger-generation');
  }
}