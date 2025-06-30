import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_track.freezed.dart';
part 'audio_track.g.dart';

@freezed
class AudioTrack with _$AudioTrack {
  const factory AudioTrack({
    required int id,
    required String title,
    @JsonKey(name: 'youtube_id') required String youtubeId,
  }) = _AudioTrack;

  factory AudioTrack.fromJson(Map<String, dynamic> json) => _$AudioTrackFromJson(json);
}
