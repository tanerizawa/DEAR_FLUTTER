import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

/// Shows the latest recommended music track.
class MusicSection extends StatelessWidget {
  const MusicSection({super.key, required this.onPlay, required this.loading});

  final Future<void> Function(AudioTrack) onPlay;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LatestMusicCubit, LatestMusicState>(
      builder: (context, state) {
        if (state.status == LatestMusicStatus.loading) {
          return const _ShimmerMusicCard();
        }
        if (state.status == LatestMusicStatus.failure) {
          return Center(
            child: Text(state.errorMessage ?? 'Terjadi kesalahan'),
          );
        }
        final track = state.track;
        if (track == null) {
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
            _MusicCard(
              track: track,
              onTap: () => onPlay(track),
              loading: loading,
            ),
          ],
        );
      },
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

class _MusicCard extends StatelessWidget {
  const _MusicCard({
    required this.track,
    required this.onTap,
    required this.loading,
  });

  final AudioTrack track;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.music_note),
        title: Text(track.title),
        subtitle: Text(track.artist ?? ''),
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
