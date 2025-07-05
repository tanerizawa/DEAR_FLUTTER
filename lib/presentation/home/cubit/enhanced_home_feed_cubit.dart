// lib/presentation/home/cubit/enhanced_home_feed_cubit.dart

import 'package:dear_flutter/domain/entities/home_feed.dart';
import 'package:dear_flutter/domain/entities/journal.dart';
import 'package:dear_flutter/domain/repositories/home_repository.dart';
import 'package:dear_flutter/domain/repositories/journal_repository.dart';
import 'package:dear_flutter/services/audio_url_cache_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:async';

import 'home_feed_state.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';

@injectable
class EnhancedHomeFeedCubit extends Cubit<HomeFeedState> {
  final HomeRepository _homeRepository;
  final JournalRepository _journalRepository;
  final AudioUrlCacheService _cacheService;
  final YoutubeExplode _yt = YoutubeExplode();
  
  Timer? _musicGenerationTimer;
  bool _isGeneratingMusic = false;

  EnhancedHomeFeedCubit(this._homeRepository, this._journalRepository, this._cacheService)
      : super(const HomeFeedState());

  @override
  Future<void> close() {
    _musicGenerationTimer?.cancel();
    return super.close();
  }

  /// Enhanced fetch with smart caching and background prefetch
  Future<void> fetchHomeFeed() async {
    if (state.status == HomeFeedStatus.loading) return;

    emit(state.copyWith(status: HomeFeedStatus.loading));
    debugPrint("[EnhancedHomeFeedCubit] Starting enhanced home feed fetch...");

    try {
      // Parallel fetch for better performance
      final results = await Future.wait([
        _homeRepository.getHomeFeed(),
        _journalRepository.getJournals().first,
      ]);

      final feed = results[0] as HomeFeed?;
      final journals = results[1] as List<Journal>;
      final lastMood = journals.isNotEmpty ? journals.first.mood : null;

      if (feed == null) {
        await _handleEmptyFeed(lastMood);
        return;
      }

      // Background prefetch for better UX
      if (feed.music != null) {
        _prefetchAudioUrl(feed.music!.youtubeId);
      }

      // Build playlist from available tracks
      final playlist = await _buildPlaylist(feed.music);

      emit(state.copyWith(
        status: HomeFeedStatus.success,
        feed: feed,
        music: feed.music,
        playlist: playlist,
        lastMood: lastMood,
      ));

      debugPrint("[EnhancedHomeFeedCubit] Successfully loaded feed with ${playlist.length} tracks");

    } catch (e, stackTrace) {
      debugPrint("[EnhancedHomeFeedCubit] Error fetching home feed: $e");
      debugPrint(stackTrace.toString());
      emit(state.copyWith(
        status: HomeFeedStatus.failure,
        errorMessage: 'Gagal memuat data. Periksa koneksi internet Anda.',
      ));
    }
  }

  /// Handle empty feed with smart music generation
  Future<void> _handleEmptyFeed(String? lastMood) async {
    debugPrint("[EnhancedHomeFeedCubit] Empty feed detected, triggering music generation...");
    
    emit(state.copyWith(
      status: HomeFeedStatus.success,
      feed: HomeFeed(musicStatus: "generating"),
      lastMood: lastMood,
    ));

    try {
      await _homeRepository.triggerMusicGeneration();
      _startMusicGenerationPolling();
    } catch (e) {
      debugPrint("[EnhancedHomeFeedCubit] Failed to trigger music generation: $e");
      emit(state.copyWith(
        status: HomeFeedStatus.failure,
        errorMessage: 'Gagal menghasilkan musik. Coba lagi nanti.',
      ));
    }
  }

  /// Smart polling for music generation status
  void _startMusicGenerationPolling() {
    if (_musicGenerationTimer != null) return;
    
    _isGeneratingMusic = true;
    _musicGenerationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) async {
        if (!_isGeneratingMusic) {
          timer.cancel();
          return;
        }

        try {
          final feed = await _homeRepository.getHomeFeed();
          
          if (feed?.music != null && feed!.musicStatus != "generating") {
            timer.cancel();
            _isGeneratingMusic = false;
            
            final playlist = await _buildPlaylist(feed.music);
            _prefetchAudioUrl(feed.music!.youtubeId);
            
            emit(state.copyWith(
              feed: feed,
              music: feed.music,
              playlist: playlist,
              status: HomeFeedStatus.success,
            ));
            
            debugPrint("[EnhancedHomeFeedCubit] Music generation completed!");
          }
        } catch (e) {
          debugPrint("[EnhancedHomeFeedCubit] Polling error: $e");
        }

        // Stop polling after 2 minutes
        if (timer.tick >= 40) {
          timer.cancel();
          _isGeneratingMusic = false;
          emit(state.copyWith(
            status: HomeFeedStatus.failure,
            errorMessage: 'Musik membutuhkan waktu lebih lama untuk disiapkan. Coba refresh nanti.',
          ));
        }
      },
    );
  }

  /// Build playlist with similar tracks
  Future<List<AudioTrack>> _buildPlaylist(AudioTrack? currentTrack) async {
    if (currentTrack == null) return [];
    
    try {
      // Start with current track
      final playlist = <AudioTrack>[currentTrack];
      
      // Try to get more tracks from the same mood/genre
      // This could be enhanced with actual API calls for similar tracks
      
      return playlist;
    } catch (e) {
      debugPrint("[EnhancedHomeFeedCubit] Error building playlist: $e");
      return [currentTrack];
    }
  }

  /// Enhanced prefetch with error handling and retries
  Future<void> _prefetchAudioUrl(String youtubeId) async {
    if (_cacheService.has(youtubeId)) {
      debugPrint("[EnhancedHomeFeedCubit] Audio URL for $youtubeId already cached");
      return;
    }

    debugPrint("[EnhancedHomeFeedCubit] Starting prefetch for $youtubeId...");
    
    try {
      await _performPrefetchWithRetry(youtubeId, maxRetries: 2);
    } catch (e) {
      debugPrint("[EnhancedHomeFeedCubit] Prefetch failed for $youtubeId: $e");
    }
  }

  Future<void> _performPrefetchWithRetry(String youtubeId, {int maxRetries = 2}) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final manifest = await _yt.videos.streamsClient.getManifest(youtubeId);
        
        AudioOnlyStreamInfo? chosen;
        
        // Prefer tag 140 (m4a 128kbps)
        try {
          chosen = manifest.audioOnly.firstWhere((e) => e.tag == 140);
        } catch (_) {
          // Filter audio with bitrate <= 128kbps
          final suitable = manifest.audioOnly
              .where((e) => e.bitrate.kiloBitsPerSecond <= 128)
              .toList();
          
          if (suitable.isNotEmpty) {
            suitable.sort((a, b) => b.bitrate.compareTo(a.bitrate));
            chosen = suitable.first;
          } else if (manifest.audioOnly.isNotEmpty) {
            // Fallback: lowest bitrate available
            final sorted = manifest.audioOnly.toList()
              ..sort((a, b) => a.bitrate.compareTo(b.bitrate));
            chosen = sorted.first;
          }
        }

        if (chosen == null) {
          throw Exception("No suitable audio stream found");
        }

        _cacheService.set(youtubeId, chosen.url.toString());
        debugPrint("[EnhancedHomeFeedCubit] Prefetch successful for $youtubeId");
        return;

      } catch (e) {
        if (attempt == maxRetries) {
          throw e;
        }
        debugPrint("[EnhancedHomeFeedCubit] Prefetch attempt ${attempt + 1} failed: $e");
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }
  }

  /// Enhanced refresh with optimistic updates
  Future<void> refreshHomeFeed() async {
    debugPrint("[EnhancedHomeFeedCubit] Starting enhanced refresh...");
    
    // Show loading state
    emit(state.copyWith(status: HomeFeedStatus.loading));
    
    try {
      // Trigger new music generation
      await _homeRepository.triggerMusicGeneration();
      
      // Start polling for new content
      await _pollForNewContent();
      
    } catch (e) {
      debugPrint("[EnhancedHomeFeedCubit] Refresh failed: $e");
      emit(state.copyWith(
        status: HomeFeedStatus.failure,
        errorMessage: 'Gagal memperbarui konten. Coba lagi.',
      ));
    }
  }

  /// Smart polling for new content
  Future<void> _pollForNewContent() async {
    final oldMusicId = state.feed?.music?.id;
    
    for (int attempt = 0; attempt < 15; attempt++) {
      await Future.delayed(const Duration(seconds: 2));
      
      try {
        final newFeed = await _homeRepository.getHomeFeed();
        
        if (newFeed?.music?.id != oldMusicId && newFeed?.music != null) {
          final playlist = await _buildPlaylist(newFeed!.music);
          _prefetchAudioUrl(newFeed.music!.youtubeId);
          
          emit(state.copyWith(
            feed: newFeed,
            music: newFeed.music,
            playlist: playlist,
            status: HomeFeedStatus.success,
          ));
          
          debugPrint("[EnhancedHomeFeedCubit] New content loaded successfully!");
          return;
        }
      } catch (e) {
        debugPrint("[EnhancedHomeFeedCubit] Polling attempt ${attempt + 1} failed: $e");
      }
    }
    
    // If we get here, polling timed out
    emit(state.copyWith(
      status: HomeFeedStatus.success,
      errorMessage: 'Konten baru sedang disiapkan. Coba refresh lagi nanti.',
    ));
  }

  /// Get music generation progress (for UI feedback)
  bool get isGeneratingMusic => _isGeneratingMusic;
  
  /// Force stop music generation polling
  void stopMusicGeneration() {
    _musicGenerationTimer?.cancel();
    _musicGenerationTimer = null;
    _isGeneratingMusic = false;
  }
}
