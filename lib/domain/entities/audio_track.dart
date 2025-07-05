import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_track.freezed.dart';
part 'audio_track.g.dart';

@freezed
class AudioTrack with _$AudioTrack {
  const factory AudioTrack({
    required int id,
    required String title,
    required String youtubeId,
    String? artist,
    String? coverUrl,
    String? streamUrl,
  }) = _AudioTrack;

  factory AudioTrack.fromJson(Map<String, dynamic> json) => _$AudioTrackFromJson(json);
}

// Freezed field mapping
extension AudioTrackJson on AudioTrack {
  @JsonKey(name: 'youtube_id')
  String? get youtubeIdJson => youtubeId;
  @JsonKey(name: 'cover_url')
  String? get coverUrlJson => coverUrl;
  @JsonKey(name: 'stream_url')
  String? get streamUrlJson => streamUrl;
}
