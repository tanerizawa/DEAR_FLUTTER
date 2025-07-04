// lib/presentation/home/screens/home_screen.dart

import 'dart:async'; // <-- PERBAIKAN: Baris ini yang terlewat dan menyebabkan error

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:dear_flutter/presentation/home/widgets/widgets.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AudioPlayerHandler _handler;
  late final StreamSubscription<PlaybackState> _playSub;
  late final StreamSubscription<Duration> _posSub;
  late final StreamSubscription<Duration?> _durSub;
  bool _isPlaying = false;
  bool _loading = false;
  AudioTrack? _currentTrack;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _handler = getIt<AudioPlayerHandler>();
    _playSub = _handler.playbackState.listen((state) async {
      if (state.processingState == AudioProcessingState.completed) {
        await _handler.seek(Duration.zero);
        if (!mounted) return;
        setState(() {
          _isPlaying = false;
          _currentTrack = null;
        });
      } else {
        if (!mounted) return;
        setState(() => _isPlaying = state.playing);
      }
    });
    _posSub = _handler.positionStream.listen((d) {
      if (!mounted) return;
      setState(() => _position = d);
    });
    _durSub = _handler.durationStream.listen((d) {
      if (d != null) {
        if (!mounted) return;
        setState(() => _duration = d);
      }
    });
  }

  @override
  void dispose() {
    _playSub.cancel();
    _posSub.cancel();
    _durSub.cancel();
    super.dispose();
  }

  Future<void> _playTrack(AudioTrack track) async {
    try {
      if (!mounted) return;
      setState(() => _loading = true);
      await getIt<SongHistoryRepository>().addTrack(track);
      await _handler.playFromYoutubeId(track.youtubeId);
      if (!mounted) return;
      setState(() {
        _currentTrack = track;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat lagu. Coba lagi.')),
      );
    }
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _handler.pause();
    } else if (_currentTrack != null) {
      await _handler.play();
    }
  }

  Future<void> _seek(double value) async {
    await _handler.seek(Duration(milliseconds: value.round()));
  }

  Future<void> _onRefresh(BuildContext ctx) async {
    await ctx.read<HomeFeedCubit>().fetchHomeFeed();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeFeedCubit(getIt())..fetchHomeFeed(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<HomeFeedCubit, HomeFeedState>(
                  builder: (context, state) {
                    return RefreshIndicator(
                      onRefresh: () => _onRefresh(context),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const QuoteSection(),
                          const SizedBox(height: 24),
                          MusicSection(
                            onPlay: _playTrack,
                            loading: _loading,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (_currentTrack != null)
                PlayerBar(
                  track: _currentTrack!,
                  isPlaying: _isPlaying,
                  isLoading: _loading,
                  position: _position,
                  duration: _duration,
                  onToggle: _toggle,
                  onSeek: _seek,
                ),
            ],
          ),
        ),
      ),
    );
  }
}