// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/services/youtube_search_service.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_state.dart';
import 'package:dear_flutter/services/audio_player_handler.dart';
import 'package:dear_flutter/domain/repositories/song_history_repository.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

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
    _playSub = _handler.playbackState.listen((state) {
      setState(() => _isPlaying = state.playing);
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

  // Play music suggestion and add to history
  Future<void> _playSuggestion(SongSuggestion suggestion) async {
    try {
      setState(() => _loading = true); // Show loading indicator

      final service = getIt<YoutubeSearchService>();
      final result = await service.search('${suggestion.title} ${suggestion.artist}');

      final track = AudioTrack(
        id: 0,
        title: suggestion.title,
        youtubeId: result.id,
        artist: suggestion.artist,
        coverUrl: result.thumbnailUrl,
      );

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
  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<LatestMusicCubit>().fetchLatestMusic(),
      context.read<LatestQuoteCubit>().fetchLatestQuote(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LatestMusicCubit>()),
        BlocProvider(create: (_) => getIt<LatestQuoteCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Beranda')),
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const _QuoteSection(),
                    const SizedBox(height: 24),
                    _MusicSection(
                      onPlay: _playSuggestion,
                      loading: _loading,
                    ),
                  ],
                ),
              ),
            ),
            if (_currentTrack != null)
              _PlayerBar(
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

// Widget for displaying quotes with shimmer loading
class _QuoteSection extends StatelessWidget {
  const _QuoteSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LatestQuoteCubit, LatestQuoteState>(
      builder: (context, state) {
        if (state.status == LatestQuoteStatus.loading) {
          return _ShimmerQuoteCard();
        }
        if (state.status == LatestQuoteStatus.failure) {
          return Center(
            child: Text(state.errorMessage ?? 'Terjadi kesalahan'),
          );
        }
        final quote = state.quote;
        if (quote == null) return const SizedBox.shrink();
        return _QuoteCard(quote: quote);
      },
    );
  }
}

// Shimmer effect for quote card while loading
class _ShimmerQuoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        child: ListTile(
          leading: Icon(Icons.format_quote, color: Colors.grey[400]),
          title: Container(height: 20.0, color: Colors.grey[400]),
          subtitle: Container(height: 15.0, color: Colors.grey[300]),
        ),
      ),
    );
  }
}

// Widget for displaying music cards
class _MusicSection extends StatelessWidget {
  const _MusicSection({required this.onPlay, required this.loading});

  final Future<void> Function(SongSuggestion) onPlay;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LatestMusicCubit, LatestMusicState>(
      builder: (context, state) {
        if (state.status == LatestMusicStatus.loading) {
          return _ShimmerMusicCard();
        }
        if (state.status == LatestMusicStatus.failure) {
          return Center(
            child: Text(state.errorMessage ?? 'Terjadi kesalahan'),
          );
        }
        if (state.suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        final suggestion = state.suggestions.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rekomendasi Musik',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _MusicCard(
              suggestion: suggestion,
              onTap: () => onPlay(suggestion),
              loading: loading,
            ),
          ],
        );
      },
    );
  }
}

// Shimmer effect for music card while loading
class _ShimmerMusicCard extends StatelessWidget {
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

// Music card widget that shows song info
class _MusicCard extends StatelessWidget {
  const _MusicCard({
    required this.suggestion,
    required this.onTap,
    required this.loading,
  });

  final SongSuggestion suggestion;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.music_note),
        title: Text(suggestion.title),
        subtitle: Text(suggestion.artist),
        onTap: onTap,
        trailing: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
      ),
    );
  }
}

// Quote card widget for displaying quotes
class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});

  final MotivationalQuote quote;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.format_quote),
        title: Text('"${quote.text}"'),
        subtitle: Text(quote.author),
        onTap: () => context.go('/quote', extra: quote),
      ),
    );
  }
}

// Player bar widget for controlling playback
class _PlayerBar extends StatelessWidget {
  const _PlayerBar({
    required this.track,
    required this.isPlaying,
    required this.isLoading,
    required this.position,
    required this.duration,
    required this.onToggle,
    required this.onSeek,
  });

  final AudioTrack track;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final VoidCallback onToggle;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final max = duration.inMilliseconds.toDouble();
    final value = position.inMilliseconds.clamp(0, max).toDouble();
    String fmt(Duration d) {
      final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      final hours = d.inHours;
      return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
    }

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            min: 0,
            max: max > 0 ? max : 1,
            value: value,
            onChanged: onSeek,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (track.coverUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      track.coverUrl!,
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(height: 40, width: 40, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${fmt(position)} / ${fmt(duration)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: onToggle,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
