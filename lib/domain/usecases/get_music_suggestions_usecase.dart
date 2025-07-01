import 'package:injectable/injectable.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:dear_flutter/domain/repositories/home_repository.dart';

@injectable
class GetMusicSuggestionsUseCase {
  final HomeRepository _repository;
  GetMusicSuggestionsUseCase(this._repository);

  Future<List<SongSuggestion>> call() => _repository.getMusicSuggestions();
}
