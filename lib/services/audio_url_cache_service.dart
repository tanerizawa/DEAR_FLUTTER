// lib/services/audio_url_cache_service.dart

import 'package:injectable/injectable.dart';

/// Layanan sederhana untuk menyimpan URL streaming audio yang sudah diekstrak
/// di dalam memori, agar bisa diakses dengan cepat nanti.
@lazySingleton
class AudioUrlCacheService {
  // Peta (Map) digunakan sebagai cache sederhana.
  // Key: youtubeId (String), Value: streamUrl (String)
  final Map<String, String> _cache = {};

  /// Menyimpan streamUrl ke dalam cache.
  /// Jika sudah ada, nilainya akan ditimpa.
  void set(String youtubeId, String streamUrl) {
    _cache[youtubeId] = streamUrl;
  }

  /// Mengambil streamUrl dari cache.
  /// Mengembalikan null jika tidak ditemukan.
  String? get(String youtubeId) {
    return _cache[youtubeId];
  }

  /// Memeriksa apakah sebuah URL sudah ada di dalam cache.
  bool has(String youtubeId) {
    return _cache.containsKey(youtubeId);
  }

  /// Menghapus seluruh isi cache. Berguna saat logout, misalnya.
  void clear() {
    _cache.clear();
  }

  /// Menghapus satu entry cache berdasarkan youtubeId.
  void remove(String youtubeId) {
    _cache.remove(youtubeId);
  }
}