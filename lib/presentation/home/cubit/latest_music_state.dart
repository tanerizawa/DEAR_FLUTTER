import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'latest_music_state.freezed.dart';

enum LatestMusicStatus { initial, loading, success, failure }

@freezed
class LatestMusicState with _$LatestMusicState {
  const factory LatestMusicState({
    @Default(LatestMusicStatus.initial) LatestMusicStatus status,
    @Default([]) List<SongSuggestion> suggestions,
    String? errorMessage,
  }) = _LatestMusicState;
}
