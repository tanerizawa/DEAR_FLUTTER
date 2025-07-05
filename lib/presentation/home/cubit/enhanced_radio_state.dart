// lib/presentation/home/cubit/enhanced_radio_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dear_flutter/domain/entities/radio_station.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';

part 'enhanced_radio_state.freezed.dart';

enum EnhancedRadioStatus { 
  initial, 
  loaded, 
  loading, 
  playing, 
  paused,
  stopped, 
  error 
}

@freezed
class EnhancedRadioState with _$EnhancedRadioState {
  const factory EnhancedRadioState({
    @Default(EnhancedRadioStatus.initial) EnhancedRadioStatus status,
    @Default([]) List<RadioStation> availableStations,
    RadioStation? currentStation,
    @Default([]) List<AudioTrack> currentPlaylist,
    String? errorMessage,
    @Default(0) int currentTrackIndex,
    @Default(false) bool isShuffled,
    @Default(false) bool isRepeating,
  }) = _EnhancedRadioState;
}
