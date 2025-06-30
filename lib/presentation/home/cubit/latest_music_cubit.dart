import 'package:dear_flutter/domain/usecases/get_latest_music_usecase.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class LatestMusicCubit extends Cubit<LatestMusicState> {
  final GetLatestMusicUseCase _getLatestMusicUseCase;

  LatestMusicCubit(this._getLatestMusicUseCase)
      : super(const LatestMusicState()) {
    fetchLatestMusic();
  }

  Future<void> fetchLatestMusic() async {
    emit(state.copyWith(status: LatestMusicStatus.loading));
    try {
      final track = await _getLatestMusicUseCase();
      emit(state.copyWith(status: LatestMusicStatus.success, track: track));
    } catch (_) {
      emit(state.copyWith(
        status: LatestMusicStatus.failure,
        errorMessage: 'Gagal memuat musik.',
      ));
    }
  }
}
