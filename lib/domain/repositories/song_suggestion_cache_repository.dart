import 'package:dear_flutter/domain/entities/song_suggestion.dart';

abstract class SongSuggestionCacheRepository {
  Future<void> saveSuggestions(List<SongSuggestion> suggestions);
  List<SongSuggestion> getLastSuggestions();
}
