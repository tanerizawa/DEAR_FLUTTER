import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_track.freezed.dart';
part 'audio_track.g.dart';

@freezed
class AudioTrack with _$AudioTrack {
  const factory AudioTrack({
    required int id,
    required String title,
    @JsonKey(name: 'youtube_id') // ignore: invalid_annotation_target
    required String youtubeId,
    String? artist,
    @JsonKey(name: 'cover_url') // ignore: invalid_annotation_target
    String? coverUrl,
  }) = _AudioTrack;

  factory AudioTrack.fromJson(Map<String, dynamic> json) => _$AudioTrackFromJson(json);
}
