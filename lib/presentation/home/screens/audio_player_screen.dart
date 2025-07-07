// lib/presentation/home/screens/audio_player_screen.dart

import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, required this.track});

  final AudioTrack track;

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late final AudioPlayerHandler _handler;
  late final StreamSubscription<PlaybackState> _playbackStateSubscription;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _buffered = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _handler = getIt<AudioPlayerHandler>();

    _playbackStateSubscription = _handler.playbackState.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
        _position = state.updatePosition;
        _buffered = state.bufferedPosition;
        _duration = _handler.mediaItem.value?.duration ?? Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _playbackStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _handler.pause();
    } else {
      await getIt<SongHistoryRepository>().addTrack(widget.track);
      try {
        // --- PERBAIKAN DI SINI: Tambahkan 'widget.track' sebagai argumen kedua ---
        await _handler.playFromYoutubeId(widget.track.youtubeId, widget.track);
      } on YoutubeExplodeException catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Gagal memutar audio dari YouTube')),
          );
      } on StateError catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Audio tidak tersedia')),
          );
      }
    }
  }

  Future<void> _seek(double value) async {
    await _handler.seek(Duration(milliseconds: value.round()));
  }

  @override
  Widget build(BuildContext context) {
    final max = _duration.inMilliseconds.toDouble();
    final value = _position.inMilliseconds.clamp(0, max).toDouble();
    final buffer = max == 0 ? 0.0 : _buffered.inMilliseconds.toDouble() / max;
    
    return Scaffold(
      appBar: AppBar(title: Text(widget.track.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.track.coverUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.track.coverUrl!,
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.music_note, size: 100, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            const SizedBox(height: 16),
            Text(widget.track.title,
                style: Theme.of(context).textTheme.headlineSmall),
            if (widget.track.artist != null)
              Text(widget.track.artist!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            Slider(
              min: 0,
              max: max > 0 ? max : 1,
              value: value,
              onChanged: _seek,
            ),
            LinearProgressIndicator(value: buffer),
            const SizedBox(height: 24),
            IconButton(
              iconSize: 64,
              icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
              onPressed: _toggle,
            ),
          ],
        ),
      ),
    );
  }
}