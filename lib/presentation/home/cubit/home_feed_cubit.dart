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
      
      // --- LOGIKA PRE-FETCH BARU ---
      if (feed.music != null) {
        // Jalankan pre-fetch tanpa menunggu hasilnya (fire and forget)
        _prefetchAudioUrl(feed.music!.youtubeId);
      }

      emit(state.copyWith(
        status: HomeFeedStatus.success,
        feed: feed,
        lastMood: lastMood,
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
      var audioUrl = manifest.audioOnly.withHighestBitrate().url;
      // Simpan URL yang berhasil didapat ke dalam cache
      _cacheService.set(youtubeId, audioUrl.toString());
      debugPrint("[HomeFeedCubit] Pre-fetch untuk $youtubeId berhasil.");
    } catch (e) {
      debugPrint("[HomeFeedCubit] Pre-fetch untuk $youtubeId gagal: $e");
    }
  }

  Future<void> refreshHomeFeed() async {
     await fetchHomeFeed();
  }
}