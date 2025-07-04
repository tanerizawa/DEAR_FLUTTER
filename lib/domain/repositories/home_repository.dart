// lib/domain/repositories/home_repository.dart

import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/home_feed.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';

/// Abstract class (kontrak) untuk semua operasi terkait data home.
/// Setiap implementasi (misalnya, dari API atau database lokal) harus menyediakan
/// fungsi-fungsi ini.
abstract class HomeRepository {
  /// Mengambil data utama untuk halaman home.
  Future<HomeFeed> getHomeFeed();

  /// Mengambil kutipan motivasi terbaru.
  Future<MotivationalQuote> getLatestQuote();

  /// Mengambil musik yang terakhir dibuat. Bisa null jika tidak ada.
  Future<AudioTrack?> getLatestMusic();

  /// Mengambil rekomendasi musik berdasarkan mood.
  Future<List<SongSuggestion>> getMusicSuggestions(String mood);
  
  /// Mengambil daftar musik untuk kategori stasiun radio tertentu.
  Future<List<AudioTrack>> getRadioStation(String category);

  /// Memicu pembuatan musik baru di backend.
  Future<void> triggerMusicGeneration();

  /// Memicu pembuatan kutipan baru di backend.
  Future<void> triggerQuoteGeneration();
}