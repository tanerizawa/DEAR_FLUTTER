// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/services/youtube_search_service.dart';
import 'package:go_router/go_router.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BlocBuilder<LatestQuoteCubit, LatestQuoteState>(
              builder: (context, state) {
                if (state.status == LatestQuoteStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == LatestQuoteStatus.failure) {
                  return Center(
                    child: Text(state.errorMessage ?? 'Terjadi kesalahan'),
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
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == LatestMusicStatus.failure) {
                  return Center(
                    child: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                  );
                }
                if (state.suggestions.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rekomendasi Musik',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ...state.suggestions
                        .map((s) => _MusicCard(suggestion: s)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicCard extends StatelessWidget {
  const _MusicCard({required this.suggestion});

  final SongSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.music_note),
        title: Text(suggestion.title),
        subtitle: Text(suggestion.artist),
        onTap: () async {
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
          if (context.mounted) {
            context.go('/audio', extra: track);
          }
        },
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
