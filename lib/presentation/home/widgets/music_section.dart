// lib/presentation/home/widgets/music_section.dart

import 'dart:async';
import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:audio_service/audio_service.dart';

class MusicSection extends StatefulWidget {
  const MusicSection({super.key});

  @override
  State<MusicSection> createState() => _MusicSectionState();
}

class _MusicSectionState extends State<MusicSection> {
  late final AudioPlayerHandler _handler;
  late final StreamSubscription<PlaybackState> _playSub;
  late final StreamSubscription<Duration> _posSub;
  late final StreamSubscription<Duration?> _durSub;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  AudioTrack? _currentTrack;

  @override
  void initState() {
    super.initState();
    _handler = getIt<AudioPlayerHandler>();

    _playSub = _handler.playbackState.listen((state) {
      if (!mounted) return;

      // --- PERBAIKAN UTAMA DI SINI ---
      // Kita hanya perlu memperbarui status 'isPlaying' dan mereset jika lagu selesai.
      // Kita tidak perlu memeriksa ID lagu di sini.
      if (state.processingState == AudioProcessingState.completed) {
        _resetState();
      } else {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    _posSub = _handler.positionStream.listen((d) {
      if (!mounted || !_isPlaying) return;
      setState(() => _position = d);
    });

    _durSub = _handler.durationStream.listen((d) {
      if (!mounted || !_isPlaying) return;
      if (d != null) {
        setState(() => _duration = d);
      }
    });
  }

  void _resetState() {
    if (!mounted) return;
    setState(() {
      _currentTrack = null;
      _isPlaying = false;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
  }

  @override
  void dispose() {
    _playSub.cancel();
    _posSub.cancel();
    _durSub.cancel();
    super.dispose();
  }

  Future<void> _handlePlayPause(AudioTrack track) async {
    // Jika lagu yang ditekan berbeda dengan yang sedang diputar
    if (_currentTrack?.id != track.id) {
      // Set _currentTrack SEBELUM memutar lagu
      setState(() {
        _currentTrack = track;
      });
      await getIt<SongHistoryRepository>().addTrack(track);
      await _handler.playFromYoutubeId(track.youtubeId);
    } else { // Jika lagu yang sama ditekan
      if (_isPlaying) {
        await _handler.pause();
      } else {
        await _handler.play();
      }
    }
  }

  Future<void> _seek(double value) async {
    await _handler.seek(Duration(milliseconds: value.round()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeFeedCubit, HomeFeedState>(
      builder: (context, state) {
        if (state.status == HomeFeedStatus.loading && state.feed == null) {
          return const _ShimmerMusicCard();
        }
        final track = state.feed?.music;
        if (track == null) {
          return const SizedBox.shrink();
        }

        // Penentuan apakah kartu ini adalah pemutar yang aktif
        final bool isActivePlayer = _currentTrack?.id == track.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rekomendasi Musik',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _MusicCard(
              track: track,
              // Kirim status isPlaying hanya jika kartu ini aktif
              isPlaying: isActivePlayer && _isPlaying,
              duration: isActivePlayer ? _duration : Duration.zero,
              position: isActivePlayer ? _position : Duration.zero,
              onTap: () => _handlePlayPause(track),
              onSeek: _seek,
            ),
          ],
        );
      },
    );
  }
}

// _MusicCard dan _ShimmerMusicCard tidak perlu diubah, bisa dibiarkan seperti sebelumnya.
class _MusicCard extends StatelessWidget {
  const _MusicCard({
    required this.track,
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.onTap,
    required this.onSeek,
  });

  final AudioTrack track;
  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final VoidCallback onTap;
  final Function(double) onSeek;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.music_note, size: 40),
            title: Text(track.title, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(track.artist ?? '', style: Theme.of(context).textTheme.bodySmall),
            trailing: IconButton(
              iconSize: 32,
              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
              onPressed: onTap,
            ),
          ),
          if (isPlaying)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Slider(
                value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()),
                max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                onChanged: onSeek,
              ),
            ),
        ],
      ),
    );
  }
}

class _ShimmerMusicCard extends StatelessWidget {
  const _ShimmerMusicCard();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        child: ListTile(
          leading: Icon(Icons.music_note, color: Colors.grey[400]),
          title: Container(height: 20.0, color: Colors.grey[400]),
          subtitle: Container(height: 15.0, color: Colors.grey[300]),
        ),
      ),
    );
  }
}