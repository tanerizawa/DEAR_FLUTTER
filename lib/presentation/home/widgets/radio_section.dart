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

          return Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Icon(
                    // Ikon berubah jika sedang diputar
                    isPlaying ? Icons.radio_button_checked_rounded : Icons.radio_rounded,
                    size: 44,
                    color: Colors.orange.shade400,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Radio Dear Diary',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.orange.shade900,
                                )),
                        const SizedBox(height: 4),
                        Text(
                          isPlaying ? "Menemani harimu..." : "Putar playlist untuk aktivitasmu",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange.shade700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  isLoading
                      ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          icon: Icon(isPlaying ? Icons.stop_circle_outlined : Icons.play_arrow_rounded, size: 44),
                          color: Colors.orange.shade700,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}