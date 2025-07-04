import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:dear_flutter/services/music_update_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/material.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/core/di/injection.dart';

@injectable
class LatestMusicCubit extends Cubit<LatestMusicState> {
  final MusicUpdateService _updateService;
  LatestMusicCubit(this._updateService) : super(const LatestMusicState()) {
    final cached = _updateService.latest;
    if (cached != null) {
      emit(state.copyWith(status: LatestMusicStatus.cached, track: cached));
    }
  }

  Future<void> fetchLatestMusic() async {
    if (_updateService.hasFetchedInitial) {
      final cached = _updateService.latest;
      if (cached != null) {
        emit(state.copyWith(status: LatestMusicStatus.success, track: cached));
      }
      return;
    }

    emit(state.copyWith(status: LatestMusicStatus.loading));
    final track = await _updateService.refresh();
    if (track != null) {
      emit(state.copyWith(status: LatestMusicStatus.success, track: track));
    } else {
      final cached = _updateService.latest;
      if (cached != null) {
        emit(state.copyWith(
          status: LatestMusicStatus.offline,
          track: cached,
          errorMessage: 'Gagal memuat musik.',
        ));
      } else {
        emit(state.copyWith(
          status: LatestMusicStatus.failure,
          errorMessage: 'Gagal memuat musik.',
        ));
      }
    }
  }

  Future<void> refreshMusicAndPlay(BuildContext context) async {
    await fetchLatestMusic();
    final track = state.track;
    if (track != null) {
      final handler = getIt<AudioPlayerHandler>();
      await handler.playFromYoutubeId(track.youtubeId, track);
    }
  }
}
