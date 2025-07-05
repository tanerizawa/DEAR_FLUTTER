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

  // Playlist state
  List<AudioTrack> _playlist = [];
  int _currentIndex = 0;
  bool _isPrefetching = false;

  Future<void> playPlaylist(List<AudioTrack> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;
    _playlist = tracks;
    _currentIndex = startIndex;
    await playFromYoutubeId(_playlist[_currentIndex].youtubeId, _playlist[_currentIndex]);
    // Listen for position to prefetch next
    _player.positionStream.listen((pos) async {
      final duration = _player.duration;
      if (duration != null && !_isPrefetching && _currentIndex < _playlist.length - 1) {
        if (duration.inSeconds - pos.inSeconds <= 10) {
          _isPrefetching = true;
          final next = _playlist[_currentIndex + 1];
          // Prefetch audioUrl & metadata
          await playFromYoutubeId(next.youtubeId, next);
          // Don't actually play, just cache
          await _player.stop();
          _isPrefetching = false;
        }
      }
    });
    // Listen for completion to auto-next
    _player.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed && _currentIndex < _playlist.length - 1) {
        _currentIndex++;
        await playFromYoutubeId(_playlist[_currentIndex].youtubeId, _playlist[_currentIndex]);
      }
    });
  }

  Future<void> playFromYoutubeId(String youtubeId, AudioTrack track) async {
    int retry = 0;
    const maxRetry = 3;
    final delays = [Duration(seconds: 1), Duration(seconds: 2), Duration(seconds: 4)];
    while (true) {
      try {
        debugPrint('[AudioPlayerHandler] Play event: ${track.title} (YouTube ID: $youtubeId)');
        String? audioUrl;
        Duration? duration;
        // --- Gunakan streamUrl dari backend jika ada ---
        if (track.streamUrl != null && track.streamUrl!.isNotEmpty) {
          debugPrint('[AudioPlayerHandler] Menggunakan streamUrl dari backend');
          audioUrl = track.streamUrl;
        } else {
          // --- Cek metadata cache dulu ---
          final cached = await _metadataCache.getMetadata(youtubeId);
          DateTime? cacheTimestamp;
          bool cacheExpired = true;
          if (cached != null && cached['timestamp'] != null) {
            cacheTimestamp = DateTime.tryParse(cached['timestamp']);
            if (cacheTimestamp != null) {
              cacheExpired = DateTime.now().difference(cacheTimestamp) > const Duration(hours: 2);
            }
          }
          if (cached != null && cached['audioUrl'] != null && !cacheExpired) {
            debugPrint("[AudioPlayerHandler] Memutar audio dari metadata cache...");
            audioUrl = cached['audioUrl'] as String;
            duration = cached['duration'] != null ? Duration(milliseconds: cached['duration']) : null;
          } else if (_cacheService.has(youtubeId) && !cacheExpired) {
            debugPrint("[AudioPlayerHandler] Memutar audio dari cache...");
            audioUrl = _cacheService.get(youtubeId);
          } else {
            debugPrint("[AudioPlayerHandler] URL tidak ada di cache, melakukan ekstraksi...");
            var manifest = await _yt.videos.streamsClient.getManifest(youtubeId);
            final audioOnlyStreams = manifest.audioOnly.toList();
            // Prioritaskan itag 140, lalu bitrate tertinggi <256kbps
            AudioOnlyStreamInfo? chosen;
            chosen = audioOnlyStreams.firstWhere(
              (e) => e.tag == 140,
              orElse: () {
                final filtered = audioOnlyStreams.where((e) => e.bitrate.kiloBitsPerSecond < 256).toList();
                if (filtered.isEmpty) return audioOnlyStreams.first;
                filtered.sort((a, b) => b.bitrate.kiloBitsPerSecond.compareTo(a.bitrate.kiloBitsPerSecond));
                return filtered.first;
              },
            );
            audioUrl = chosen.url.toString();
            // YoutubeExplode tidak expose durasi di stream, ambil dari Video objek
            final video = await _yt.videos.get(youtubeId);
            duration = video.duration;
            // Simpan ke cache dengan timestamp
            _cacheService.set(youtubeId, audioUrl);
            await _metadataCache.saveMetadata(track, audioUrl, duration);
          }
        }
        if (audioUrl == null) {
          throw Exception("Tidak dapat menemukan URL audio yang valid.");
        }
        final mediaItem = MediaItem(
          id: track.id.toString(),
          title: track.title,
          artist: track.artist,
          artUri: track.coverUrl != null ? Uri.parse(track.coverUrl!) : null,
          duration: duration,
        );
        this.mediaItem.add(mediaItem);
        try {
          await _player.setAudioSource(AudioSource.uri(Uri.parse(audioUrl), tag: mediaItem));
          await play();
        } catch (audioError) {
          debugPrint('[AudioPlayerHandler] Error saat setAudioSource/play: $audioError');
          // Jika error saat play dari cache, hapus cache dan retry
          _cacheService.remove(youtubeId);
          await _metadataCache.removeMetadata(youtubeId);
          throw audioError;
        }
        // Setelah berhasil set audio, simpan metadata ke cache (termasuk durasi aktual)
        await _metadataCache.saveMetadata(track, audioUrl, _player.duration);
        break; // success
      } catch (e) {
        debugPrint('[AudioPlayerHandler] Error playing from YouTube ID: $e (retry $retry)');
        if (retry < maxRetry) {
          await Future.delayed(delays[retry]);
          retry++;
          continue;
        } else {
          rethrow;
        }
      }
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

  AudioPlayer get player => _player;
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