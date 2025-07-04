// lib/presentation/home/widgets/radio_section.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/home/cubit/radio_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/radio_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RadioSection extends StatelessWidget {
  const RadioSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Sediakan RadioCubit untuk widget ini
    return BlocProvider(
      create: (_) => getIt<RadioCubit>(),
      child: BlocBuilder<RadioCubit, RadioState>(
        builder: (context, state) {
          // Tentukan status radio saat ini
          final bool isPlaying = state.status == RadioStatus.playing;
          final bool isLoading = state.status == RadioStatus.loading;

          return Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Icon(
                // Ikon berubah jika sedang diputar
                isPlaying ? Icons.radio_button_checked_rounded : Icons.radio_rounded,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Radio Dear Diary', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                isPlaying ? "Menemani harimu..." : "Putar playlist untuk aktivitasmu",
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
                          // Selalu putar kategori 'santai' sebagai default
                          cubit.playRadio('santai');
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