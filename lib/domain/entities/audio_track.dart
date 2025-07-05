import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_track.freezed.dart';
part 'audio_track.g.dart';

@freezed
class AudioTrack with _$AudioTrack {
  @JsonSerializable(fieldRename: FieldRename.snake)
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
