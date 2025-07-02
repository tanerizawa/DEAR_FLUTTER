import 'package:dear_flutter/domain/usecases/get_music_suggestions_usecase.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:dear_flutter/domain/repositories/song_suggestion_cache_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class LatestMusicCubit extends Cubit<LatestMusicState> {
  final GetMusicSuggestionsUseCase _getMusicSuggestionsUseCase;
  final SongSuggestionCacheRepository _cacheRepository;
  bool _hasFetched = false;

  LatestMusicCubit(
    this._getMusicSuggestionsUseCase,
    this._cacheRepository,
  ) : super(const LatestMusicState()) {
    fetchLatestMusic();
  }

  Future<void> fetchLatestMusic() async {
    if (_hasFetched) {
      debugPrint('fetchLatestMusic skipped: already fetched');
      return;
    }
    _hasFetched = true;

    final cached = _cacheRepository.getLastSuggestions();
    final hasCache = cached.isNotEmpty;
    if (hasCache) {
      emit(state.copyWith(
          status: LatestMusicStatus.cached, suggestions: cached));
    } else {
      emit(state.copyWith(status: LatestMusicStatus.loading));
    }
    try {
      final suggestions = await _getMusicSuggestionsUseCase('Netral');
      emit(state.copyWith(
          status: LatestMusicStatus.success, suggestions: suggestions));
      await _cacheRepository.saveSuggestions(suggestions);
    } catch (_) {
      if (!hasCache) {
        emit(state.copyWith(
          status: LatestMusicStatus.failure,
          errorMessage: 'Gagal memuat musik.',
        ));
      }
    }
  }
}
