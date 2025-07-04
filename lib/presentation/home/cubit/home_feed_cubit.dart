// lib/presentation/home/cubit/home_feed_cubit.dart

import 'package:dear_flutter/domain/entities/home_feed.dart';
import 'package:dear_flutter/domain/entities/journal.dart';
import 'package:dear_flutter/domain/repositories/home_repository.dart';
import 'package:dear_flutter/domain/repositories/journal_repository.dart';
import 'package:dear_flutter/services/audio_url_cache_service.dart';
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
  final YoutubeExplode _yt = YoutubeExplode();

  HomeFeedCubit(this._homeRepository, this._journalRepository, this._cacheService)
      : super(const HomeFeedState());

  Future<void> fetchHomeFeed() async {
    if (state.status == HomeFeedStatus.loading) return;

    emit(state.copyWith(status: HomeFeedStatus.loading));
    debugPrint("[HomeFeedCubit] Mulai mengambil data home feed dan jurnal...");

    try {
      final results = await Future.wait([
        _homeRepository.getHomeFeed(),
        _journalRepository.getJournals().first,
      ]);

      final feed = results[0] as HomeFeed;
      final journals = results[1] as List<Journal>;
      final lastMood = journals.isNotEmpty ? journals.first.mood : null;

      debugPrint("[HomeFeedCubit] DATA BERHASIL DITERIMA. Mood terakhir: $lastMood");
      // Fallback: jika playlist kosong, isi dengan 1 lagu dari music
      final playlist = (feed.playlist.isNotEmpty)
          ? List<AudioTrack>.from(feed.playlist)
          : (feed.music != null ? [feed.music!] : <AudioTrack>[]);
      if (playlist.isNotEmpty) {
        for (final track in playlist) {
          _prefetchAudioUrl(track.youtubeId);
        }
      }
      emit(state.copyWith(
        status: HomeFeedStatus.success,
        feed: feed,
        lastMood: lastMood,
        playlist: playlist,
        activeIndex: 0,
      ));
    } catch (e, stackTrace) {
      debugPrint("[HomeFeedCubit] GAGAL MENGAMBIL DATA: $e");
      debugPrint(stackTrace.toString());
      emit(state.copyWith(
        status: HomeFeedStatus.failure,
        errorMessage: 'Gagal memuat data. Silakan coba lagi.',
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
    try {
      await _homeRepository.triggerMusicGeneration();
    } catch (e) {
      debugPrint('[HomeFeedCubit] triggerMusicGeneration gagal: $e');
    }
    // Polling sampai lagu benar-benar berubah (max 5x percobaan, delay 1 detik)
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 1));
      try {
        final newFeed = await _homeRepository.getHomeFeed();
        if (oldFeed == null || newFeed.music?.title != oldFeed.music?.title || newFeed.music?.artist != oldFeed.music?.artist) {
          emit(state.copyWith(feed: newFeed, status: HomeFeedStatus.success));
          // Jalankan prefetch jika ada lagu baru
          if (newFeed.music != null) {
            _prefetchAudioUrl(newFeed.music!.youtubeId);
          }
          return;
        }
      } catch (e) {
        debugPrint('[HomeFeedCubit] Polling gagal: $e');
      }
    }
    // Jika gagal berubah, fallback ke fetch biasa
    await fetchHomeFeed();
  }

  /// Ambil playlist lagu (5 lagu sekaligus) dari endpoint khusus jika ada
  Future<void> fetchPlaylist() async {
    emit(state.copyWith(status: HomeFeedStatus.loading));
    try {
      // Coba ambil playlist dari endpoint khusus (misal: music/playlist)
      // Jika tidak ada, fallback ke getHomeFeed
      List<AudioTrack> playlist = [];
      try {
        playlist = await _homeRepository.getRadioStation('santai'); // Ganti dengan endpoint playlist jika ada
      } catch (_) {}
      if (playlist.isEmpty) {
        final feed = await _homeRepository.getHomeFeed();
        playlist = feed.playlist.isNotEmpty ? feed.playlist : (feed.music != null ? [feed.music!] : []);
      }
      if (playlist.isEmpty) throw Exception('Playlist kosong');
      for (final track in playlist) {
        _prefetchAudioUrl(track.youtubeId);
      }
      emit(state.copyWith(
        status: HomeFeedStatus.success,
        playlist: playlist,
        activeIndex: 0,
      ));
    } catch (e) {
      debugPrint('[HomeFeedCubit] Gagal fetch playlist: $e');
      emit(state.copyWith(status: HomeFeedStatus.failure, errorMessage: 'Gagal memuat playlist.'));
    }
  }

  /// Pindah ke lagu berikutnya di playlist, jika habis fetch playlist baru
  Future<void> nextSong() async {
    final currIdx = state.activeIndex;
    final playlist = state.playlist;
    if (playlist.isEmpty || currIdx + 1 >= playlist.length) {
      // Playlist habis, fetch baru
      await fetchPlaylist();
      return;
    }
    emit(state.copyWith(activeIndex: currIdx + 1));
  }
}