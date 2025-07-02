import 'package:dear_flutter/domain/repositories/song_suggestion_cache_repository.dart';
import 'package:dear_flutter/domain/usecases/get_music_suggestions_usecase.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetMusicSuggestionsUseCase extends Mock
    implements GetMusicSuggestionsUseCase {}

class _FakeCacheRepo implements SongSuggestionCacheRepository {
  List<SongSuggestion> suggestions = const [];

  @override
  Future<void> saveSuggestions(List<SongSuggestion> suggestions) async {
    this.suggestions = suggestions;
  }

  @override
  List<SongSuggestion> getLastSuggestions() => suggestions;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('emits cached suggestions when api fails', () async {
    final usecase = _MockGetMusicSuggestionsUseCase();
    final cache = _FakeCacheRepo()
      ..suggestions = const [SongSuggestion(title: 't', artist: 'a')];
    when(() => usecase('Netral')).thenThrow(Exception());

    final cubit = LatestMusicCubit(usecase, cache);
    final states = <LatestMusicState>[];
    final sub = cubit.stream.listen(states.add);

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(states, hasLength(1));
    expect(states.first.status, LatestMusicStatus.cached);
    expect(states.first.suggestions, cache.suggestions);
    await sub.cancel();
  });

  test('fetchLatestMusic only calls api once', () async {
    final usecase = _MockGetMusicSuggestionsUseCase();
    final cache = _FakeCacheRepo();
    when(() => usecase('Netral')).thenAnswer((_) async => []);

    final cubit = LatestMusicCubit(usecase, cache);
    await cubit.fetchLatestMusic();

    verify(() => usecase('Netral')).called(1);
  });
}
