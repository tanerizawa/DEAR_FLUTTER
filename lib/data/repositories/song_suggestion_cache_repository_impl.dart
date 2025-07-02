import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:dear_flutter/domain/repositories/song_suggestion_cache_repository.dart';

@LazySingleton(as: SongSuggestionCacheRepository)
class SongSuggestionCacheRepositoryImpl implements SongSuggestionCacheRepository {
  final Box<Map> _box;

  SongSuggestionCacheRepositoryImpl(@Named('suggestionBox') this._box);

  @override
  Future<void> saveSuggestions(List<SongSuggestion> suggestions) =>
      _box.put('latest',
          {'items': suggestions.map((e) => e.toJson()).toList()});

  @override
  List<SongSuggestion> getLastSuggestions() {
    final data = _box.get('latest');
    if (data == null) return [];
    final items = List<Map>.from(data['items'] as List);
    return items
        .map((e) =>
            SongSuggestion.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
