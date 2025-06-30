import 'package:injectable/injectable.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/repositories/home_repository.dart';

@injectable
class GetLatestMusicUseCase {
  final HomeRepository _repository;
  GetLatestMusicUseCase(this._repository);

  Future<AudioTrack> call() => _repository.getLatestMusic();
}
