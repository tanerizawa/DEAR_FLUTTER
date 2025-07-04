// lib/presentation/home/cubit/radio_cubit.dart

import 'package:dear_flutter/domain/repositories/home_repository.dart';
import 'package:dear_flutter/services/radio_audio_player_handler.dart';
import 'package:dear_flutter/services/radio_playlist_cache_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';

import 'radio_state.dart';

@injectable
class RadioCubit extends Cubit<RadioState> {
  final HomeRepository _homeRepository;
  final RadioAudioPlayerHandler _audioHandler;
  final RadioPlaylistCacheService _playlistCache = RadioPlaylistCacheService();

  RadioCubit(this._homeRepository, this._audioHandler) : super(const RadioState());

  Future<void> playRadio(String category) async {
    // Jika radio dengan kategori yang sama sudah berjalan, jangan lakukan apa-apa
    if (state.status == RadioStatus.playing && state.activeCategory == category) {
      debugPrint("[RadioCubit] Radio untuk kategori '$category' sudah berjalan.");
      return;
    }
    emit(state.copyWith(status: RadioStatus.loading, activeCategory: category));
    debugPrint("[RadioCubit] Meminta playlist untuk kategori: $category");
    try {
      // 1. Cek cache dulu
      List<AudioTrack> playlist = await _playlistCache.getPlaylist(category);
      if (playlist.isEmpty) {
        // 2. Jika cache kosong, fetch dari API
        playlist = await _homeRepository.getRadioStation(category);
        if (playlist.isEmpty) {
          throw Exception('Playlist yang diterima kosong.');
        }
        // Simpan ke cache
        await _playlistCache.savePlaylist(category, playlist);
      }
      debugPrint("[RadioCubit] Playlist diterima, berisi "+playlist.length.toString()+" lagu.");
      // 2. Kirim playlist ke audio handler untuk diputar
      await _audioHandler.playPlaylist(playlist);
      
      // 3. Update state menjadi playing
      emit(state.copyWith(
        status: RadioStatus.playing,
        playlist: playlist,
      ));

    } catch (e) {
      debugPrint("[RadioCubit] Gagal memutar radio: $e");
      emit(state.copyWith(
        status: RadioStatus.failure,
        errorMessage: 'Gagal memulai radio.',
      ));
    }
  }

  /// Refresh manual playlist radio (paksa fetch API dan update cache)
  Future<void> refreshRadioPlaylist(String category) async {
    emit(state.copyWith(status: RadioStatus.loading, activeCategory: category));
    try {
      final playlist = await _homeRepository.getRadioStation(category);
      if (playlist.isEmpty) throw Exception('Playlist kosong.');
      await _playlistCache.savePlaylist(category, playlist);
      await _audioHandler.playPlaylist(playlist);
      emit(state.copyWith(
        status: RadioStatus.playing,
        playlist: playlist,
      ));
    } catch (e) {
      debugPrint("[RadioCubit] Gagal refresh radio: $e");
      emit(state.copyWith(
        status: RadioStatus.failure,
        errorMessage: 'Gagal refresh radio.',
      ));
    }
  }

  // Fungsi untuk menghentikan radio
  Future<void> stopRadio() async {
    await _audioHandler.stop();
    emit(const RadioState(status: RadioStatus.initial)); // Kembali ke state awal
    debugPrint("[RadioCubit] Radio dihentikan.");
  }
}