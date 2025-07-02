import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:injectable/injectable.dart';

import 'youtube_audio_service.dart';

/// [AudioPlayerHandler] manages playback using [AudioPlayer] and exposes
/// controls via `audio_service`.
@LazySingleton()
class AudioPlayerHandler extends BaseAudioHandler {
  AudioPlayerHandler(this._youtube, {AudioPlayer? player})
      : _player = player ?? AudioPlayer() {
    _player.playerStateStream.listen(_broadcastState);
  }

  final YoutubeAudioService _youtube;
  final AudioPlayer _player;
  String? _currentId;

  Future<void> _broadcastState(PlayerState state) async {
    playbackState.add(
      PlaybackState(
        playing: state.playing,
        processingState: _mapProcessingState(state.processingState),
        controls: const [MediaControl.play, MediaControl.pause, MediaControl.stop],
      ),
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  /// Resolve [youtubeId] and begin playback.
  Future<void> playFromYoutubeId(String youtubeId) async {
    try {
      if (_currentId != youtubeId) {
        final url = await _youtube.getAudioUrl(youtubeId);
        await _player.setUrl(url);
        _currentId = youtubeId;
      }
      await _player.play();
    } on PlayerException catch (e) {
      debugPrint('Player error: ${e.message}');
      rethrow;
    } on PlayerInterruptedException catch (e) {
      debugPrint('Playback interrupted: ${e.message}');
    }
  }

  @override
  Future<void> play() async {
    try {
      await _player.play();
    } on PlayerException catch (e) {
      debugPrint('Player error: ${e.message}');
      rethrow;
    } on PlayerInterruptedException catch (e) {
      debugPrint('Playback interrupted: ${e.message}');
    }
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.dispose();
    _youtube.close();
    return super.stop();
  }

}
