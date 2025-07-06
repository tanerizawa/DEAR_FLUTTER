// lib/presentation/home/cubit/enhanced_radio_cubit.dart

import 'dart:async';
import 'package:dear_flutter/domain/entities/radio_station.dart';
import 'package:dear_flutter/domain/repositories/home_repository.dart';
import 'package:dear_flutter/services/radio_audio_player_handler.dart';
import 'package:dear_flutter/services/radio_playlist_cache_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';

import 'enhanced_radio_state.dart';

@injectable
class EnhancedRadioCubit extends Cubit<EnhancedRadioState> {
  final HomeRepository _homeRepository;
  final RadioAudioPlayerHandler _audioHandler;
  final RadioPlaylistCacheService _playlistCache = RadioPlaylistCacheService();
  
  Timer? _playlistUpdateTimer;
  Timer? _listenerCountTimer;

  EnhancedRadioCubit(this._homeRepository, this._audioHandler) 
      : super(const EnhancedRadioState()) {
    _initializeRadioStations();
  }

  @override
  Future<void> close() {
    _playlistUpdateTimer?.cancel();
    _listenerCountTimer?.cancel();
    return super.close();
  }

  // Initialize with predefined radio stations
  Future<void> _initializeRadioStations() async {
    final predefinedStations = _createPredefinedStations();
    emit(state.copyWith(
      availableStations: predefinedStations,
      status: EnhancedRadioStatus.loaded,
    ));
  }

  List<RadioStation> _createPredefinedStations() {
    return RadioCategory.values.map((category) {
      return RadioStation(
        id: category.id,
        name: '${category.emoji} Radio ${category.displayName}',
        category: category.id,
        description: category.description,
        imageUrl: _getCategoryImageUrl(category),
        color: _getCategoryColor(category),
        tags: _getCategoryTags(category),
        listeners: _getRandomListeners(),
        isLive: true,
      );
    }).toList();
  }

  String? _getCategoryImageUrl(RadioCategory category) {
    // In real app, these would be actual image URLs
    final imageMap = {
      RadioCategory.santai: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300',
      RadioCategory.energik: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300',
      RadioCategory.fokus: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
      RadioCategory.bahagia: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300',
      RadioCategory.sedih: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300',
      RadioCategory.romantis: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=300',
      RadioCategory.nostalgia: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300',
      RadioCategory.instrumental: 'https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=300',
      RadioCategory.jazz: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300',
      RadioCategory.rock: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300',
      RadioCategory.pop: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300',
      RadioCategory.electronic: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300',
    };
    return imageMap[category];
  }

  String _getCategoryColor(RadioCategory category) {
    final colorMap = {
      RadioCategory.santai: '#4A90E2',      // Blue
      RadioCategory.energik: '#F5A623',     // Orange
      RadioCategory.fokus: '#7ED321',       // Green
      RadioCategory.bahagia: '#F8E71C',     // Yellow
      RadioCategory.sedih: '#50E3C2',       // Teal
      RadioCategory.romantis: '#D0021B',    // Red
      RadioCategory.nostalgia: '#9013FE',   // Purple
      RadioCategory.instrumental: '#BD10E0', // Pink
      RadioCategory.jazz: '#B8E986',        // Light Green
      RadioCategory.rock: '#417505',        // Dark Green
      RadioCategory.pop: '#FF6B35',         // Coral
      RadioCategory.electronic: '#1DB954',  // Spotify Green
    };
    return colorMap[category] ?? '#1DB954';
  }

  List<String> _getCategoryTags(RadioCategory category) {
    final tagMap = {
      RadioCategory.santai: ['chill', 'relax', 'ambient', 'peaceful'],
      RadioCategory.energik: ['upbeat', 'motivational', 'workout', 'dance'],
      RadioCategory.fokus: ['instrumental', 'concentration', 'study', 'productivity'],
      RadioCategory.bahagia: ['happy', 'uplifting', 'positive', 'cheerful'],
      RadioCategory.sedih: ['melancholy', 'emotional', 'ballad', 'contemplative'],
      RadioCategory.romantis: ['love', 'romantic', 'intimate', 'soulful'],
      RadioCategory.nostalgia: ['classic', 'vintage', 'memories', 'timeless'],
      RadioCategory.instrumental: ['no vocals', 'classical', 'cinematic', 'atmospheric'],
      RadioCategory.jazz: ['smooth', 'sophisticated', 'lounge', 'swing'],
      RadioCategory.rock: ['guitar', 'alternative', 'indie', 'energetic'],
      RadioCategory.pop: ['mainstream', 'catchy', 'contemporary', 'hits'],
      RadioCategory.electronic: ['synth', 'beats', 'digital', 'futuristic'],
    };
    return tagMap[category] ?? [];
  }

  int _getRandomListeners() {
    return (50 + (DateTime.now().millisecond % 200));
  }

  // Play specific radio station
  Future<void> playRadioStation(RadioStation station) async {
    if (state.status == EnhancedRadioStatus.playing && 
        state.currentStation?.id == station.id) {
      debugPrint("[EnhancedRadioCubit] Radio station '${station.name}' is already playing.");
      return;
    }

    emit(state.copyWith(
      status: EnhancedRadioStatus.loading,
      currentStation: station,
      errorMessage: null, // Clear previous error
    ));

    debugPrint("[EnhancedRadioCubit] Starting radio station: ${station.name}");

    try {
      // 1. Check cache first
      List<AudioTrack> playlist = await _playlistCache.getPlaylist(station.category);
      
      if (playlist.isEmpty) {
        // 2. Fetch from API with retry logic
        playlist = await _fetchPlaylistWithRetry(station.category, maxRetries: 3);
        if (playlist.isEmpty) {
          throw Exception('Unable to load ${station.name} playlist. Please check your internet connection.');
        }
        // Save to cache
        await _playlistCache.savePlaylist(station.category, playlist);
      }

      debugPrint("[EnhancedRadioCubit] Playlist loaded with ${playlist.length} tracks");

      // 3. Send playlist to audio handler
      await _audioHandler.playPlaylist(playlist);

      // 4. Update station with playlist
      final updatedStation = station.copyWith(playlist: playlist);

      // 5. Update state to playing
      emit(state.copyWith(
        status: EnhancedRadioStatus.playing,
        currentStation: updatedStation,
        currentPlaylist: playlist,
      ));

      // 6. Start background timers
      _startBackgroundTimers();

    } catch (e) {
      String errorMessage;
      if (e.toString().contains('404') || e.toString().contains('Not Found')) {
        errorMessage = 'Radio station ${station.name} is temporarily unavailable. Try another station.';
      } else if (e.toString().contains('network') || e.toString().contains('timeout')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      } else {
        errorMessage = 'Failed to start ${station.name}. Please try again.';
      }
      
      debugPrint("[EnhancedRadioCubit] Failed to play radio station: $e");
      emit(state.copyWith(
        status: EnhancedRadioStatus.error,
        errorMessage: errorMessage,
      ));
    }
  }

  // Fetch playlist with retry logic
  Future<List<AudioTrack>> _fetchPlaylistWithRetry(String category, {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint("[EnhancedRadioCubit] Fetching playlist for $category (attempt $attempt/$maxRetries)");
        final playlist = await _homeRepository.getRadioStation(category);
        if (playlist.isNotEmpty) {
          return playlist;
        }
        if (attempt == maxRetries) {
          throw Exception('No tracks found for category $category');
        }
      } catch (e) {
        debugPrint("[EnhancedRadioCubit] Attempt $attempt failed: $e");
        if (attempt == maxRetries) {
          rethrow;
        }
        // Wait before retry with exponential backoff
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    return [];
  }

  // Stop current radio
  Future<void> stopRadio() async {
    await _audioHandler.stop();
    _stopBackgroundTimers();
    
    emit(state.copyWith(
      status: EnhancedRadioStatus.stopped,
      currentStation: null,
      currentPlaylist: [],
    ));
    
    debugPrint("[EnhancedRadioCubit] Radio stopped.");
  }

  // Pause current radio
  Future<void> pauseRadio() async {
    if (state.status != EnhancedRadioStatus.playing) return;
    
    await _audioHandler.pause();
    emit(state.copyWith(status: EnhancedRadioStatus.paused));
    
    debugPrint("[EnhancedRadioCubit] Radio paused.");
  }

  // Resume current radio
  Future<void> resumeRadio() async {
    if (state.status != EnhancedRadioStatus.paused) return;
    
    await _audioHandler.play();
    emit(state.copyWith(status: EnhancedRadioStatus.playing));
    
    debugPrint("[EnhancedRadioCubit] Radio resumed.");
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (state.status == EnhancedRadioStatus.playing) {
      await pauseRadio();
    } else if (state.status == EnhancedRadioStatus.paused) {
      await resumeRadio();
    } else if (state.currentStation != null) {
      await playRadioStation(state.currentStation!);
    }
  }

  // Refresh current station playlist
  Future<void> refreshCurrentStation() async {
    final currentStation = state.currentStation;
    if (currentStation == null) return;

    emit(state.copyWith(status: EnhancedRadioStatus.loading));

    try {
      // Force fetch from API
      final playlist = await _homeRepository.getRadioStation(currentStation.category);
      if (playlist.isEmpty) {
        throw Exception('Empty playlist received during refresh');
      }

      // Update cache
      await _playlistCache.savePlaylist(currentStation.category, playlist);

      // Update audio handler
      await _audioHandler.playPlaylist(playlist);

      // Update state
      final updatedStation = currentStation.copyWith(playlist: playlist);
      emit(state.copyWith(
        status: EnhancedRadioStatus.playing,
        currentStation: updatedStation,
        currentPlaylist: playlist,
      ));

      debugPrint("[EnhancedRadioCubit] Station refreshed with ${playlist.length} tracks");

    } catch (e) {
      debugPrint("[EnhancedRadioCubit] Failed to refresh station: $e");
      emit(state.copyWith(
        status: EnhancedRadioStatus.error,
        errorMessage: 'Failed to refresh station. Please try again.',
      ));
    }
  }

  // Get stations by category
  List<RadioStation> getStationsByCategory(RadioCategory category) {
    return state.availableStations
        .where((station) => station.category == category.id)
        .toList();
  }

  // Search stations
  List<RadioStation> searchStations(String query) {
    if (query.isEmpty) return state.availableStations;
    
    query = query.toLowerCase();
    return state.availableStations.where((station) {
      return station.name.toLowerCase().contains(query) ||
             station.description.toLowerCase().contains(query) ||
             station.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  // Background timers for live updates
  void _startBackgroundTimers() {
    _stopBackgroundTimers();

    // Update listener count every 30 seconds
    _listenerCountTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _updateListenerCount(),
    );

    // Update playlist every 10 minutes
    _playlistUpdateTimer = Timer.periodic(
      const Duration(minutes: 10),
      (timer) => _backgroundPlaylistUpdate(),
    );
  }

  void _stopBackgroundTimers() {
    _playlistUpdateTimer?.cancel();
    _listenerCountTimer?.cancel();
    _playlistUpdateTimer = null;
    _listenerCountTimer = null;
  }

  void _updateListenerCount() {
    final currentStation = state.currentStation;
    if (currentStation == null) return;

    // Simulate dynamic listener count
    final newCount = _getRandomListeners();
    final updatedStation = currentStation.copyWith(listeners: newCount);

    emit(state.copyWith(currentStation: updatedStation));
  }

  Future<void> _backgroundPlaylistUpdate() async {
    final currentStation = state.currentStation;
    if (currentStation == null) return;

    try {
      // Silently fetch new playlist in background
      final newPlaylist = await _homeRepository.getRadioStation(currentStation.category);
      if (newPlaylist.isNotEmpty && newPlaylist.length != state.currentPlaylist.length) {
        // Update cache silently
        await _playlistCache.savePlaylist(currentStation.category, newPlaylist);
        debugPrint("[EnhancedRadioCubit] Background playlist updated");
      }
    } catch (e) {
      debugPrint("[EnhancedRadioCubit] Background playlist update failed: $e");
    }
  }

  // Get favorite stations (for future implementation)
  List<RadioStation> getFavoriteStations() {
    // TODO: Implement with local storage
    return state.availableStations.take(3).toList();
  }

  // Toggle favorite station (for future implementation)
  Future<void> toggleFavoriteStation(RadioStation station) async {
    // TODO: Implement with local storage
    debugPrint("[EnhancedRadioCubit] Toggle favorite for ${station.name}");
  }

  // Show station list (go back from current station)
  void showStationList() {
    _stopBackgroundTimers();
    
    emit(state.copyWith(
      status: EnhancedRadioStatus.loaded,
      currentStation: null,
      currentPlaylist: [],
    ));
    
    debugPrint("[EnhancedRadioCubit] Showing station list.");
  }

  // Retry playing current station (for error recovery)
  Future<void> retryCurrentStation() async {
    final currentStation = state.currentStation;
    if (currentStation != null) {
      debugPrint("[EnhancedRadioCubit] Retrying current station: ${currentStation.name}");
      await playRadioStation(currentStation);
    }
  }

  // Clear error state
  void clearError() {
    if (state.status == EnhancedRadioStatus.error) {
      emit(state.copyWith(
        status: EnhancedRadioStatus.stopped,
        errorMessage: null,
      ));
    }
  }
}
