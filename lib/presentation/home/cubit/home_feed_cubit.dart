// lib/presentation/home/cubit/home_feed_cubit.dart

import 'package:dear_flutter/domain/entities/home_feed.dart';
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
class HomeFeedCubit extends Cubit<HomeFeedState> {
  final HomeRepository _homeRepository;
  final JournalRepository _journalRepository;
  final AudioUrlCacheService _cacheService;
  final RateLimitingService _rateLimitingService = RateLimitingService();
  final YoutubeExplode _yt = YoutubeExplode();

  HomeFeedCubit(this._homeRepository, this._journalRepository, this._cacheService)
      : super(const HomeFeedState());

  Future<void> fetchHomeFeed() async {
    if (state.status == HomeFeedStatus.loading) return;

    // Check rate limits before making request
    if (!await _rateLimitingService.canMakeRequest('music_fetch')) {
      final waitTime = _rateLimitingService.getRemainingCooldown('music_fetch');
      debugPrint("[HomeFeedCubit] Rate limited, wait ${waitTime.inSeconds}s");
      
      emit(state.copyWith(
        status: HomeFeedStatus.failure,
        errorMessage: 'Tunggu ${waitTime.inSeconds} detik sebelum mencoba lagi.'
      ));
      return;
    }

    emit(state.copyWith(status: HomeFeedStatus.loading));
    debugPrint("[HomeFeedCubit] Mulai mengambil data home feed dan jurnal...");

    try {
      final results = await Future.wait([
        _homeRepository.getLatestMusic(),
        _journalRepository.getJournals().first,
      ]);
      final music = results[0] as AudioTrack?;
      final journals = results[1] as List<Journal>;
      final lastMood = journals.isNotEmpty ? journals.first.mood : null;
      
      // Auto-trigger music generation jika tidak ada musik
      if (music == null) {
        debugPrint("[HomeFeedCubit] Tidak ada musik, trigger generasi musik...");
        try {
          await _homeRepository.triggerMusicGeneration();
          // Tunggu sebentar lalu coba ambil lagi
          await Future.delayed(const Duration(seconds: 3));
          final newMusic = await _homeRepository.getLatestMusic();
          if (newMusic != null) {
            _prefetchAudioUrl(newMusic.youtubeId);
            emit(state.copyWith(
              status: HomeFeedStatus.success,
              music: newMusic,
              lastMood: lastMood,
            ));
            return;
          }
        } catch (e) {
          debugPrint("[HomeFeedCubit] Gagal trigger generasi musik: $e");
        }
      }
      
      if (music != null) {
        _prefetchAudioUrl(music.youtubeId);
      }
      emit(state.copyWith(
        status: HomeFeedStatus.success,
        music: music,
        lastMood: lastMood,
      ));
    } catch (e, stackTrace) {
      debugPrint("[HomeFeedCubit] GAGAL MENGAMBIL DATA: $e");
      debugPrint(stackTrace.toString());
      
      String errorMessage = 'Gagal memuat data. Silakan coba lagi.';
      
      // Handle specific error types for better user experience
      if (e.toString().contains('TimeoutException') || 
          e.toString().contains('Connection timeout') ||
          e.toString().contains('429') ||
          e.toString().contains('Too Many Requests')) {
        errorMessage = 'Server sedang sibuk. Silakan tunggu beberapa saat dan coba lagi.';
      } else if (e.toString().contains('Connection refused') ||
                 e.toString().contains('No route to host')) {
        errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Masalah jaringan. Periksa koneksi internet Anda.';
      }
      
      emit(state.copyWith(
        status: HomeFeedStatus.failure,
        errorMessage: errorMessage,
      ));
    }
  }

  /// Fungsi helper untuk mengambil URL audio di latar belakang.
  Future<void> _prefetchAudioUrl(String youtubeId) async {
    // Jangan lakukan apa-apa jika URL sudah ada di cache
    if (_cacheService.has(youtubeId)) {
      debugPrint("[HomeFeedCubit] Audio URL untuk $youtubeId sudah ada di cache.");
      return;
    }
    
    debugPrint("[HomeFeedCubit] Memulai pre-fetch untuk $youtubeId...");
    try {
      var manifest = await _yt.videos.streamsClient.getManifest(youtubeId);
      // Pilih tag 140 (m4a 128kbps) jika ada, jika tidak cari bitrate <= 128kbps (medium/below)
      AudioOnlyStreamInfo? chosen;
      try {
        chosen = manifest.audioOnly.firstWhere((e) => e.tag == 140);
      } catch (_) {
        // Filter hanya audio dengan bitrate <= 128kbps (medium/below)
        final within = manifest.audioOnly
            .where((e) => e.bitrate.kiloBitsPerSecond <= 128)
            .toList();
        within.sort((a, b) => b.bitrate.compareTo(a.bitrate)); // Ambil yang terbesar di bawah batas
        if (within.isNotEmpty) {
          chosen = within.first;
        } else if (manifest.audioOnly.isNotEmpty) {
          // fallback: pilih audio dengan bitrate terendah
          final sorted = manifest.audioOnly.toList()
            ..sort((a, b) => a.bitrate.compareTo(b.bitrate));
          chosen = sorted.first;
        } else {
          throw Exception("Tidak ada audio-only stream yang tersedia.");
        }
      }
      var audioUrl = chosen.url;
      // Simpan URL yang berhasil didapat ke dalam cache
      _cacheService.set(youtubeId, audioUrl.toString());
      debugPrint("[HomeFeedCubit] Pre-fetch untuk $youtubeId berhasil.");
    } catch (e) {
      debugPrint("[HomeFeedCubit] Pre-fetch untuk $youtubeId gagal: $e");
    }
  }

  Future<void> refreshHomeFeed() async {
    // Paksa backend untuk generate lagu baru
    HomeFeed? oldFeed = state.feed;
    int? oldMusicId = oldFeed?.music?.id;
    try {
      await _homeRepository.triggerMusicGeneration();
    } catch (e) {
      debugPrint('[HomeFeedCubit] triggerMusicGeneration gagal: $e');
    }
    // Polling sampai lagu benar-benar berubah (max 12x percobaan, delay 1 detik)
    for (int i = 0; i < 12; i++) {
      await Future.delayed(const Duration(seconds: 1));
      try {
        final newFeed = await _homeRepository.getHomeFeed();
        // Handle null response (204 No Content)
        if (newFeed == null) {
          debugPrint('[HomeFeedCubit] Polling: No content available (204)');
          continue;
        }
        final newMusicId = newFeed.music?.id;
        if (oldFeed == null || newMusicId != oldMusicId) {
          emit(state.copyWith(feed: newFeed, status: HomeFeedStatus.success));
          // Jalankan prefetch jika ada lagu baru
          if (newFeed.music != null) {
            _prefetchAudioUrl(newFeed.music!.youtubeId);
          }
          return;
        }
      } catch (e) {
        debugPrint('[HomeFeedCubit] Polling home feed gagal: $e');
      }
    }
    // Jika tidak ada perubahan setelah polling, emit state lama
    emit(state.copyWith(status: HomeFeedStatus.success));
  }
}