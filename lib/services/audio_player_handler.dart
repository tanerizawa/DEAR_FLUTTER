// lib/services/audio_player_handler.dart

import 'package:audio_service/audio_service.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:injectable/injectable.dart';
import 'package:dear_flutter/services/audio_url_cache_service.dart';

@lazySingleton
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();
  final AudioUrlCacheService _cacheService;

  AudioPlayerHandler(this._cacheService) {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  Future<void> playPlaylist(List<AudioTrack> tracks) async {
    // ... (implementasi playPlaylist tetap sama)
  }

  Future<void> playFromYoutubeId(String youtubeId, AudioTrack track) async {
    try {
      String? audioUrl;
      
      // --- LOGIKA BARU: PERIKSA CACHE DULU ---
      if (_cacheService.has(youtubeId)) {
        debugPrint("[AudioPlayerHandler] Memutar audio dari cache...");
        audioUrl = _cacheService.get(youtubeId);
      } else {
        // Fallback: jika tidak ada di cache, ekstrak seperti biasa
        debugPrint("[AudioPlayerHandler] URL tidak ada di cache, melakukan ekstraksi...");
        var manifest = await _yt.videos.streamsClient.getManifest(youtubeId);
        audioUrl = manifest.audioOnly.withHighestBitrate().url.toString();
        // Simpan ke cache untuk penggunaan berikutnya
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
      await play();
    } catch (e) {
      debugPrint('[AudioPlayerHandler] Error playing from YouTube ID: $e');
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