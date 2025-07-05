import 'package:audio_service/audio_service.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:injectable/injectable.dart';
import 'package:dear_flutter/services/audio_url_cache_service.dart';
import 'package:dear_flutter/services/audio_metadata_cache_service.dart';

@lazySingleton
class RadioAudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();
  final AudioUrlCacheService _cacheService;
  final AudioMetadataCacheService _metadataCache = AudioMetadataCacheService();

  RadioAudioPlayerHandler(this._cacheService) {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  // Duplikat dari AudioPlayerHandler
  Future<void> playPlaylist(List<AudioTrack> tracks) async {
    // Implementasi mirip AudioPlayerHandler
    // Untuk demo, cukup play lagu pertama
    if (tracks.isNotEmpty) {
      await playFromYoutubeId(tracks.first.youtubeId, tracks.first);
    }
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

  Future<void> playFromYoutubeId(String youtubeId, AudioTrack track) async {
    // Minimal: copy dari AudioPlayerHandler
    try {
      String? audioUrl;
      if (_cacheService.has(youtubeId)) {
        audioUrl = _cacheService.get(youtubeId);
      } else {
        var manifest = await _yt.videos.streamsClient.getManifest(youtubeId);
        // Pilih hanya stream audio-only (itag 140 atau bitrate <= 128kbps), tolak video stream apapun
        final audioOnlyStreams = manifest.audioOnly.where((e) =>
          (e.tag == 140 || e.bitrate.kiloBitsPerSecond <= 128) &&
          (e.codec.mimeType.contains('audio') || e.codec.mimeType.startsWith('audio/'))
        ).toList();
        if (audioOnlyStreams.isEmpty) {
          throw Exception('Tidak ada audio-only stream yang valid (itag 140 atau <=128kbps).');
        }
        // Prefer itag 140 jika ada, jika tidak ambil bitrate tertinggi <=128kbps
        AudioOnlyStreamInfo chosen;
        try {
          chosen = audioOnlyStreams.firstWhere((e) => e.tag == 140);
        } catch (_) {
          audioOnlyStreams.sort((a, b) => a.bitrate.compareTo(b.bitrate));
          chosen = audioOnlyStreams.last;
        }
        audioUrl = chosen.url.toString();
        _cacheService.set(youtubeId, audioUrl);
      }
      if (audioUrl == null) {
        throw Exception("Tidak dapat menemukan URL audio yang valid.");
      }
      final mediaItem = MediaItem(
        id: track.id.toString(),
        title: track.title,
        artist: track.artist,
        artUri: track.coverUrl != null ? Uri.parse(track.coverUrl!) : null,
      );
      this.mediaItem.add(mediaItem);
      await _player.setAudioSource(AudioSource.uri(Uri.parse(audioUrl), tag: mediaItem));
      await _player.play();
    } catch (e) {
      debugPrint('[RadioAudioPlayerHandler] Error playing from YouTube ID: $e');
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    debugPrint('[RadioAudioPlayerHandler] Play requested');
    await _player.play();
  }

  @override
  Future<void> pause() async {
    debugPrint('[RadioAudioPlayerHandler] Pause requested');
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    debugPrint('[RadioAudioPlayerHandler] Stop requested');
    await _player.stop();
    mediaItem.add(null);
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  void dispose() {
    _player.dispose();
    _yt.close();
  }
}
