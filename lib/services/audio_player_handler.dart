import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'youtube_audio_service.dart';

/// [AudioPlayerHandler] manages playback using [AudioPlayer] and exposes
/// controls via `audio_service`.
@LazySingleton()
class AudioPlayerHandler extends BaseAudioHandler {
  /// Creates a handler managing [AudioPlayer] playback.
  ///
  /// The optional [player] can be supplied for testing. When omitted, a new
  /// [AudioPlayer] is created. To customize buffering behavior provide a
  /// [loadConfiguration], otherwise the default configuration is used.
  AudioPlayerHandler(
    this._youtube, {
    AudioPlayer? player,
    AudioLoadConfiguration? loadConfiguration,
  }) : _player =
            player ?? AudioPlayer(audioLoadConfiguration: loadConfiguration ?? const AudioLoadConfiguration()) {
    _player.playerStateStream.listen(_broadcastState);
  }

  final YoutubeAudioService _youtube;
  final AudioPlayer _player;
  String? _currentId;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

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
  ///
  /// Throws a [YoutubeExplodeException] if resolving the video fails or a
  /// [StateError] when no suitable audio stream is found. A
  /// [PlayerException] may also be thrown if playback fails.
  Future<void> playFromYoutubeId(String youtubeId) async {
    try {
      if (_currentId != youtubeId) {
        String url;
        try {
          url = await _youtube.getAudioUrl(youtubeId);
        } on YoutubeExplodeException catch (e) {
          debugPrint('Failed to resolve YouTube audio: $e');
          rethrow;
        } on StateError catch (e) {
          debugPrint('No suitable audio stream: ${e.message}');
          rethrow;
        }
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
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.dispose();
    _youtube.close();
    return super.stop();
  }

}
