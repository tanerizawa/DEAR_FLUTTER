import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/services/youtube_audio_service.dart';
import 'package:dear_flutter/core/di/injection.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, required this.track});

  final AudioTrack track;

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late final AudioPlayer _player;
  late final YoutubeAudioService _youtube;
  String? _resolvedUrl;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _youtube = getIt<YoutubeAudioService>();
    _player.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _youtube.close();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      _resolvedUrl ??= await _youtube.getAudioUrl(widget.track.youtubeId);
      if (_resolvedUrl != null) {
        await _player.play(UrlSource(_resolvedUrl!));
      }
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
