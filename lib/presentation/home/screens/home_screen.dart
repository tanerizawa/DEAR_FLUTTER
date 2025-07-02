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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AudioPlayerHandler _handler;
  late final StreamSubscription<PlaybackState> _playSub;
  bool _isPlaying = false;
  AudioTrack? _currentTrack;

  @override
  void initState() {
    super.initState();
    _handler = getIt<AudioPlayerHandler>();
    _playSub = _handler.playbackState
        .listen((state) => setState(() => _isPlaying = state.playing));
  }

  @override
  void dispose() {
    _playSub.cancel();
    super.dispose();
  }

  Future<void> _playSuggestion(SongSuggestion suggestion) async {
    final service = getIt<YoutubeSearchService>();
    final result =
        await service.search('${suggestion.title} ${suggestion.artist}');
    final track = AudioTrack(
      id: 0,
      title: suggestion.title,
      youtubeId: result.id,
      artist: suggestion.artist,
      coverUrl: result.thumbnailUrl,
    );
    await getIt<SongHistoryRepository>().addTrack(track);
    await _handler.playFromYoutubeId(track.youtubeId);
    setState(() => _currentTrack = track);
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _handler.pause();
    } else if (_currentTrack != null) {
      await _handler.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LatestMusicCubit>()),
        BlocProvider(create: (_) => getIt<LatestQuoteCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Beranda'),
        ),
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final musicCubit = context.read<LatestMusicCubit>();
                  final quoteCubit = context.read<LatestQuoteCubit>();
                  await musicCubit.fetchLatestMusic();
                  await quoteCubit.fetchLatestQuote();
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    BlocBuilder<LatestQuoteCubit, LatestQuoteState>(
                      builder: (context, state) {
                        if (state.status == LatestQuoteStatus.loading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state.status == LatestQuoteStatus.failure) {
                          return Center(
                            child:
                                Text(state.errorMessage ?? 'Terjadi kesalahan'),
                          );
                        }
                        final quote = state.quote;
                        if (quote == null) {
                          return const SizedBox.shrink();
                        }
                        return _QuoteCard(quote: quote);
                      },
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<LatestMusicCubit, LatestMusicState>(
                      builder: (context, state) {
                        if (state.status == LatestMusicStatus.loading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state.status == LatestMusicStatus.failure) {
                          return Center(
                            child: Text(
                                state.errorMessage ?? 'Terjadi kesalahan'),
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
                              style:
                                  Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            _MusicCard(
                              suggestion: suggestion,
                              onTap: () => _playSuggestion(suggestion),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_currentTrack != null)
              _PlayerBar(
                track: _currentTrack!,
                isPlaying: _isPlaying,
                onToggle: _toggle,
              ),
          ],
        ),
      ),
    );
  }
}

class _MusicCard extends StatelessWidget {
  const _MusicCard({required this.suggestion, required this.onTap});

  final SongSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.music_note),
        title: Text(suggestion.title),
        subtitle: Text(suggestion.artist),
        onTap: onTap,
      ),
    );
  }
}

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

class _PlayerBar extends StatelessWidget {
  const _PlayerBar({
    required this.track,
    required this.isPlaying,
    required this.onToggle,
  });

  final AudioTrack track;
  final bool isPlaying;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
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
              child: Text(
                track.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}
