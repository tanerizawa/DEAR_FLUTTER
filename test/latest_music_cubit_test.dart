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

  test('loads cached suggestions on init', () async {
    final usecase = _MockGetMusicSuggestionsUseCase();
    final cache = _FakeCacheRepo()
      ..suggestions = const [SongSuggestion(title: 't', artist: 'a')];

    final cubit = LatestMusicCubit(usecase, cache);

    expect(cubit.state.status, LatestMusicStatus.cached);
    expect(cubit.state.suggestions, cache.suggestions);
  });

  test('fetchLatestMusic retrieves suggestions from api', () async {
    final usecase = _MockGetMusicSuggestionsUseCase();
    final cache = _FakeCacheRepo();
    when(() => usecase('Netral'))
        .thenAnswer((_) async => const [SongSuggestion(title: 't', artist: 'a')]);

    final cubit = LatestMusicCubit(usecase, cache);
    await cubit.fetchLatestMusic();

    expect(cubit.state.status, LatestMusicStatus.success);
    expect(cubit.state.suggestions, isNotEmpty);
    verify(() => usecase('Netral')).called(1);
  });
}
