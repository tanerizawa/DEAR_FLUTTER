// lib/presentation/home/cubit/improved_home_feed_cubit.dart

import 'dart:async';
import 'package:dear_flutter/domain/entities/journal.dart';
import 'package:dear_flutter/domain/repositories/home_repository.dart';
import 'package:dear_flutter/domain/repositories/journal_repository.dart';
import 'package:dear_flutter/services/audio_url_cache_service.dart';
import 'package:dear_flutter/services/rate_limiting_service.dart';
import 'package:dear_flutter/core/error/app_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'home_feed_state.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';

@injectable
class ImprovedHomeFeedCubit extends Cubit<HomeFeedState> {
  final HomeRepository _homeRepository;
  final JournalRepository _journalRepository;
  final AudioUrlCacheService _cacheService;
  final RateLimitingService _rateLimitingService = RateLimitingService();
  final YoutubeExplode _yt = YoutubeExplode();

  ImprovedHomeFeedCubit(
    this._homeRepository, 
    this._journalRepository, 
    this._cacheService
  ) : super(const HomeFeedState());

  Future<void> fetchHomeFeed({bool forceRefresh = false}) async {
    if (state.status == HomeFeedStatus.loading) return;

    // Check rate limits before making request
    if (!await _rateLimitingService.canMakeRequest('music_fetch')) {
      final nextAvailable = _rateLimitingService.getNextAvailableTime('music_fetch');
      final waitTime = nextAvailable?.difference(DateTime.now()) ?? Duration.zero;
      
      debugPrint("[ImprovedHomeFeedCubit] Rate limited, next available: $nextAvailable");
      
      final error = AppError(
        message: 'Tunggu ${waitTime.inSeconds} detik sebelum mencoba lagi.',
        type: ErrorType.rateLimit,
        code: 'RATE_LIMIT_EXCEEDED',
      );
      
      emit(state.copyWith(
        status: HomeFeedStatus.failure,
        errorMessage: error.message,
      ));
      return;
    }

    emit(state.copyWith(status: HomeFeedStatus.loading));
    debugPrint("[ImprovedHomeFeedCubit] Fetching home feed...");

    try {
      // Record the request attempt
      _rateLimitingService.recordRequest('music_fetch');

      final results = await Future.wait([
        _homeRepository.getLatestMusic(),
        _journalRepository.getJournals().first,
      ]).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timeout', const Duration(seconds: 30)),
      );

      final music = results[0] as AudioTrack?;
      final journals = results[1] as List<Journal>;
      final lastMood = journals.isNotEmpty ? journals.first.mood : null;
      
      // Auto-trigger music generation if no music and not rate limited
      if (music == null && !forceRefresh) {
        debugPrint("[ImprovedHomeFeedCubit] No music found, triggering generation...");
        
        if (await _rateLimitingService.canMakeRequest('music_fetch')) {
          try {
            await _homeRepository.triggerMusicGeneration();
            _rateLimitingService.recordRequest('music_fetch');
            
            // Wait and retry once
            await Future.delayed(const Duration(seconds: 3));
            final newMusic = await _homeRepository.getLatestMusic();
            
            if (newMusic != null) {
              _safePrefetchAudioUrl(newMusic.youtubeId);
            }
            
            emit(state.copyWith(
              status: HomeFeedStatus.success,
              music: newMusic,
              lastMood: lastMood,
            ));
            return;
          } catch (e) {
            debugPrint("[ImprovedHomeFeedCubit] Music generation failed: $e");
            _rateLimitingService.recordFailedRequest('music_fetch');
          }
        }
      }
      
      // Prefetch audio URL in background if music exists
      if (music != null) {
        _safePrefetchAudioUrl(music.youtubeId);
      }
      
      emit(state.copyWith(
        status: HomeFeedStatus.success,
        music: music,
        lastMood: lastMood,
      ));
      
    } catch (e, stackTrace) {
      debugPrint("[ImprovedHomeFeedCubit] Error: $e");
      debugPrint(stackTrace.toString());
      
      // Record failed request
      _rateLimitingService.recordFailedRequest('music_fetch');
      
      // Parse error using error handler
      final appError = AppErrorHandler.parseError(e);
      
      emit(state.copyWith(
        status: HomeFeedStatus.failure,
        errorMessage: appError.message,
      ));
    }
  }

  /// Safely prefetch audio URL without blocking UI
  Future<void> _safePrefetchAudioUrl(String youtubeId) async {
    // Don't prefetch if already cached
    if (_cacheService.has(youtubeId)) {
      debugPrint("[ImprovedHomeFeedCubit] Audio URL for $youtubeId already cached");
      return;
    }
    
    // Don't prefetch if rate limited
    if (!await _rateLimitingService.canMakeRequest('youtube_search')) {
      debugPrint("[ImprovedHomeFeedCubit] Skipping prefetch due to rate limit");
      return;
    }
    
    debugPrint("[ImprovedHomeFeedCubit] Starting prefetch for $youtubeId");
    
    try {
      _rateLimitingService.recordRequest('youtube_search');
      
      final manifest = await _yt.videos.streamsClient.getManifest(youtubeId)
          .timeout(const Duration(seconds: 15));
      
      AudioOnlyStreamInfo? chosen;
      
      // Try to get 140 tag (m4a 128kbps) first
      try {
        chosen = manifest.audioOnly.firstWhere((e) => e.tag == 140);
      } catch (_) {
        // Fallback: find best quality under 128kbps
        final suitable = manifest.audioOnly
            .where((e) => e.bitrate.kiloBitsPerSecond <= 128)
            .toList();
            
        if (suitable.isNotEmpty) {
          suitable.sort((a, b) => b.bitrate.compareTo(a.bitrate));
          chosen = suitable.first;
        } else if (manifest.audioOnly.isNotEmpty) {
          // Last resort: lowest bitrate available
          final sorted = manifest.audioOnly.toList()
            ..sort((a, b) => a.bitrate.compareTo(b.bitrate));
          chosen = sorted.first;
        }
      }
      
      if (chosen != null) {
        _cacheService.set(youtubeId, chosen.url.toString());
        debugPrint("[ImprovedHomeFeedCubit] Prefetch successful for $youtubeId");
      } else {
        throw Exception("No suitable audio stream found");
      }
      
    } catch (e) {
      debugPrint("[ImprovedHomeFeedCubit] Prefetch failed for $youtubeId: $e");
      _rateLimitingService.recordFailedRequest('youtube_search');
      
      // Don't emit error for prefetch failures as it's background operation
    }
  }

  /// Get rate limiting statistics
  Map<String, dynamic> getRateLimitStats() {
    return _rateLimitingService.getAllStats();
  }

  /// Check if we can make a music request
  Future<bool> canRequestMusic() async {
    return await _rateLimitingService.canMakeRequest('music_fetch');
  }

  /// Get suggested wait time before next request
  Duration getRecommendedWaitTime() {
    final nextAvailable = _rateLimitingService.getNextAvailableTime('music_fetch');
    if (nextAvailable != null) {
      return nextAvailable.difference(DateTime.now());
    }
    return Duration.zero;
  }

  @override
  Future<void> close() async {
    _yt.close();
    await _rateLimitingService.saveToStorage();
    return super.close();
  }
}
