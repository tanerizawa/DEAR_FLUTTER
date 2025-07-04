// lib/presentation/home/widgets/radio_section.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/home/cubit/radio_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/radio_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RadioSection extends StatelessWidget {
  final String title;
  final String category;
  final IconData icon;

  const RadioSection({
    super.key,
    required this.title,
    required this.category,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Sediakan RadioCubit khusus untuk widget ini
    return BlocProvider(
      create: (_) => getIt<RadioCubit>(),
      child: BlocBuilder<RadioCubit, RadioState>(
        builder: (context, state) {
          // Tentukan apakah radio ini sedang aktif
          final bool isPlaying = state.status == RadioStatus.playing && state.activeCategory == category;
          final bool isLoading = state.status == RadioStatus.loading && state.activeCategory == category;

          return Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                isPlaying ? "Sedang diputar..." : "Sentuh untuk memulai",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                      icon: Icon(isPlaying ? Icons.stop_circle_outlined : Icons.play_arrow_rounded, size: 32),
                      onPressed: () {
                        final cubit = context.read<RadioCubit>();
                        if (isPlaying) {
                          cubit.stopRadio();
                        } else {
                          cubit.playRadio(category);
                        }
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}