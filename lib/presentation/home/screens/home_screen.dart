// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_state.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:dear_flutter/presentation/home/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Home page showing the latest quote and music recommendation.

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
        setState(() {
          _isPlaying = false;
          _currentTrack = null;
        });
      } else {
        setState(() => _isPlaying = state.playing);
      }
    });
    _posSub = _handler.positionStream.listen((d) {
      setState(() => _position = d);
    });
    _durSub = _handler.durationStream.listen((d) {
      if (d != null) {
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

  // Play selected track and add to history
  Future<void> _playTrack(AudioTrack track) async {
    try {
      setState(() => _loading = true); // Show loading indicator

      // Save track to history and start playback
      await getIt<SongHistoryRepository>().addTrack(track);
      await _handler.playFromYoutubeId(track.youtubeId);
      if (!mounted) return;
      setState(() {
        _currentTrack = track;
        _loading = false; // Hide loading indicator
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false); // Hide loading indicator on error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat lagu. Coba lagi.')),
      );
    }
  }

  // Toggle play/pause
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

  // Handle refresh
  Future<void> _onRefresh(BuildContext ctx) async {
    await Future.wait([
      ctx.read<LatestMusicCubit>().fetchLatestMusic(),
      ctx.read<LatestQuoteCubit>().fetchLatestQuote(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<LatestMusicCubit>()..fetchLatestMusic(),
        ),
        BlocProvider(
          create: (_) => getIt<LatestQuoteCubit>()..fetchLatestQuote(),
        ),
      ],
      child: Scaffold(
        appBar: null,
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
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
    );
  }
}

