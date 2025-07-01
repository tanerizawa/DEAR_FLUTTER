import 'package:dear_flutter/domain/usecases/get_music_suggestions_usecase.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class LatestMusicCubit extends Cubit<LatestMusicState> {
  final GetMusicSuggestionsUseCase _getMusicSuggestionsUseCase;

  LatestMusicCubit(this._getMusicSuggestionsUseCase)
      : super(const LatestMusicState()) {
    fetchLatestMusic();
  }

  Future<void> fetchLatestMusic() async {
    emit(state.copyWith(status: LatestMusicStatus.loading));
    try {
      final suggestions = await _getMusicSuggestionsUseCase();
      emit(state.copyWith(
          status: LatestMusicStatus.success, suggestions: suggestions));
    } catch (_) {
      emit(state.copyWith(
        status: LatestMusicStatus.failure,
        errorMessage: 'Gagal memuat musik.',
      ));
    }
  }
}
