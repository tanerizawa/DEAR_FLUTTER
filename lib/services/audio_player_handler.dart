// lib/services/audio_player_handler.dart

import 'package:audio_service/audio_service.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:injectable/injectable.dart';
import 'package:dear_flutter/services/audio_url_cache_service.dart';
import 'package:dear_flutter/services/audio_metadata_cache_service.dart';
import 'package:dear_flutter/services/radio_audio_player_handler.dart';

@lazySingleton
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();
  final AudioUrlCacheService _cacheService;
  final AudioMetadataCacheService _metadataCache = AudioMetadataCacheService();

  AudioPlayerHandler(this._cacheService) {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  Future<void> playPlaylist(List<AudioTrack> tracks) async {
    // ... (implementasi playPlaylist tetap sama)
  }

  Future<void> playFromYoutubeId(String youtubeId, AudioTrack track) async {
    try {
      String? audioUrl;
      Duration? duration;
      // --- Cek metadata cache dulu ---
      final cached = await _metadataCache.getMetadata(youtubeId);
      if (cached != null && cached['audioUrl'] != null) {
        debugPrint("[AudioPlayerHandler] Memutar audio dari metadata cache...");
        audioUrl = cached['audioUrl'] as String;
        duration = cached['duration'] != null ? Duration(milliseconds: cached['duration']) : null;
      } else if (_cacheService.has(youtubeId)) {
        debugPrint("[AudioPlayerHandler] Memutar audio dari cache...");
        audioUrl = _cacheService.get(youtubeId);
      } else {
        // Fallback: ekstrak dari YouTube
        debugPrint("[AudioPlayerHandler] URL tidak ada di cache, melakukan ekstraksi...");
        var manifest = await _yt.videos.streamsClient.getManifest(youtubeId);
        // Hanya pilih dari manifest.audioOnly, tidak pernah dari video/muxed
        final audioOnlyStreams = manifest.audioOnly.where((e) =>
          (e.tag == 140 || e.bitrate.kiloBitsPerSecond <= 128) &&
          (e.codec.mimeType.contains('audio') || e.codec.mimeType.startsWith('audio/'))
        ).toList();
        if (audioOnlyStreams.isEmpty) {
          debugPrint('[AudioPlayerHandler] manifest.audioOnly: ' + manifest.audioOnly.map((e) => 'itag:${e.tag}, bitrate:${e.bitrate.kiloBitsPerSecond}, mime:${e.codec.mimeType}').join(' | '));
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
        duration: duration, // gunakan durasi dari cache jika ada
      );
      this.mediaItem.add(mediaItem);
      await _player.setAudioSource(AudioSource.uri(Uri.parse(audioUrl), tag: mediaItem));
      await play();
      // Setelah berhasil set audio, simpan metadata ke cache (termasuk durasi aktual)
      await _metadataCache.saveMetadata(track, audioUrl, _player.duration);
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

  Duration? get currentDuration => _player.duration;

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