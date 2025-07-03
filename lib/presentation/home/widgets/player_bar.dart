import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:flutter/material.dart';

/// Player bar widget for controlling playback.
class PlayerBar extends StatelessWidget {
  const PlayerBar({
    super.key,
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
