import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_track.freezed.dart';

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

  factory AudioTrack.fromJson(Map<String, dynamic> json) {
    return AudioTrack(
      id: json['id'] as int,
      title: json['title'] as String,
      youtubeId: json['youtube_id'] as String,
      artist: json['artist'] as String?,
      coverUrl: json['cover_url'] as String?,
      streamUrl: json['stream_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'youtube_id': youtubeId,
      'artist': artist,
      'cover_url': coverUrl,
      'stream_url': streamUrl,
    };
  }
}
