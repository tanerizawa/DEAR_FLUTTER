// lib/presentation/home/cubit/radio_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';

part 'radio_state.freezed.dart';

enum RadioStatus { initial, loading, playing, failure }

@freezed
class RadioState with _$RadioState {
  const factory RadioState({
    @Default(RadioStatus.initial) RadioStatus status,
    // Menyimpan kategori yang sedang aktif
    String? activeCategory,
    // Menyimpan daftar putar yang sedang diputar
    @Default([]) List<AudioTrack> playlist,
    String? errorMessage,
  }) = _RadioState;
}