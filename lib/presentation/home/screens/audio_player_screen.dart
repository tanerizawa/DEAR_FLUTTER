import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/core/di/injection.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, required this.track});

  final AudioTrack track;

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late final AudioPlayerHandler _handler;
  late final StreamSubscription<PlaybackState> _sub;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _handler = getIt<AudioPlayerHandler>();
    _sub = _handler.playbackState.listen((state) {
      setState(() => _isPlaying = state.playing);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _handler.pause();
    } else {
      await _handler.playFromYoutubeId(widget.track.youtubeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.track.title)),
      body: Center(
        child: IconButton(
          iconSize: 64,
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: _toggle,
        ),
      ),
    );
  }
}
