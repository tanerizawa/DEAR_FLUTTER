import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'latest_music_state.freezed.dart';

enum LatestMusicStatus { initial, loading, cached, offline, success, failure }

@freezed
class LatestMusicState with _$LatestMusicState {
  const factory LatestMusicState({
    @Default(LatestMusicStatus.initial) LatestMusicStatus status,
    AudioTrack? track,
    String? errorMessage,
  }) = _LatestMusicState;
}
