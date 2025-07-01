import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_suggestion.freezed.dart';
part 'song_suggestion.g.dart';

@freezed
class SongSuggestion with _$SongSuggestion {
  const factory SongSuggestion({
    required String title,
    required String artist,
  }) = _SongSuggestion;

  factory SongSuggestion.fromJson(Map<String, dynamic> json) =>
      _$SongSuggestionFromJson(json);
}
