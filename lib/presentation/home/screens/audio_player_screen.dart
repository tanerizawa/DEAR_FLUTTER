import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Fullscreen audio player for a single track.

class AudioPlayerScreen extends StatefulWidget {

  const AudioPlayerScreen({super.key, required this.track});

  final AudioTrack track;

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late final AudioPlayerHandler _handler;
  late final StreamSubscription<PlaybackState> _sub;
  late final StreamSubscription<Duration> _posSub;
  late final StreamSubscription<Duration> _bufSub;
  late final StreamSubscription<Duration?> _durSub;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _buffered = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _handler = getIt<AudioPlayerHandler>();
    _sub = _handler.playbackState.listen((state) {
      setState(() => _isPlaying = state.playing);
    });
    _posSub = _handler.positionStream.listen((d) {
      setState(() => _position = d);
    });
    _bufSub = _handler.bufferedPositionStream.listen((d) {
      setState(() => _buffered = d);
    });
    _durSub = _handler.durationStream.listen((d) {
      if (d != null) {
        setState(() => _duration = d);
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    _posSub.cancel();
    _bufSub.cancel();
    _durSub.cancel();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _handler.pause();
    } else {
      await getIt<SongHistoryRepository>().addTrack(widget.track);
      try {
        await _handler.playFromYoutubeId(widget.track.youtubeId);
        if (!mounted) return;
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
    final buffer =
        max == 0 ? 0.0 : _buffered.inMilliseconds.toDouble() / max;
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
                color: Colors.grey,
              ),
            const SizedBox(height: 16),
            Text(widget.track.title,
                style: Theme.of(context).textTheme.titleLarge),
            if (widget.track.artist != null)
              Text(widget.track.artist!),
            const SizedBox(height: 24),
            Slider(
              min: 0,
              max: max > 0 ? max : 1,
              value: value,
              onChanged: (v) => _seek(v),
            ),
            LinearProgressIndicator(value: buffer),
            const SizedBox(height: 24),
            IconButton(
              iconSize: 64,
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _toggle,
            ),
          ],
        ),
      ),
    );
  }
}
