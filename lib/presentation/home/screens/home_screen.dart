// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LatestMusicCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Beranda'),
        ),
        body: BlocBuilder<LatestMusicCubit, LatestMusicState>(
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
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Rekomendasi Musik',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ...state.suggestions
                    .map((s) => _MusicCard(suggestion: s))
                    .toList(),
              ],
            );
          },
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
      ),
    );
  }
}
