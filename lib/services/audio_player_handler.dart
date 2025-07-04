// lib/services/audio_player_handler.dart

import 'package:audio_service/audio_service.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();

  AudioPlayerHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  Future<void> playPlaylist(List<AudioTrack> tracks) async {
    if (tracks.isEmpty) return;

    final mediaItems = tracks.map((track) => MediaItem(
      id: track.id.toString(),
      title: track.title,
      artist: track.artist,
      artUri: track.coverUrl != null ? Uri.parse(track.coverUrl!) : null,
    )).toList();

    final audioSources = <AudioSource>[];
    for (int i = 0; i < tracks.length; i++) {
      try {
        var manifest = await _yt.videos.streamsClient.getManifest(tracks[i].youtubeId);
        var audioUrl = manifest.audioOnly.withHighestBitrate().url;
        audioSources.add(AudioSource.uri(audioUrl, tag: mediaItems[i]));
      } catch (e) {
        debugPrint('Gagal memproses lagu ${tracks[i].title}: $e');
      }
    }

    if (audioSources.isEmpty) {
      debugPrint('Tidak ada lagu yang valid untuk diputar di playlist.');
      return;
    }
    
    // PERBAIKAN: Menggunakan metode baru untuk playlist
    await _player.setAudioSource(
      ConcatenatingAudioSource(children: audioSources),
      initialIndex: 0,
      initialPosition: Duration.zero
    );
    
    queue.add(mediaItems);
    await play();
  }

  Future<void> playFromYoutubeId(String youtubeId, AudioTrack track) async {
    try {
      var manifest = await _yt.videos.streamsClient.getManifest(youtubeId);
      var audioUrl = manifest.audioOnly.withHighestBitrate().url;

      final mediaItem = MediaItem(
        id: track.id.toString(),
        title: track.title,
        artist: track.artist,
        artUri: track.coverUrl != null ? Uri.parse(track.coverUrl!) : null,
      );
      
      this.mediaItem.add(mediaItem);
      
      await _player.setAudioSource(AudioSource.uri(Uri.parse(audioUrl.toString()), tag: mediaItem));
      await play();
    } catch (e) {
      debugPrint('Error playing from YouTube ID: $e');
      rethrow;
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}