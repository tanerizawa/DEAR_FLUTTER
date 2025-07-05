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
    return BlocProvider(
      create: (_) => getIt<RadioCubit>(),
      child: BlocBuilder<RadioCubit, RadioState>(
        builder: (context, state) {
          final bool isPlaying = state.status == RadioStatus.playing;
          final bool isLoading = state.status == RadioStatus.loading;

          return Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  colors: [Color(0xFF232526), Color(0xFF1DB954).withOpacity(0.15)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 32,
                    offset: Offset(0, 16),
                  ),
                ],
                border: Border.all(color: Color(0x1A1A1A).withOpacity(0.15), width: 1.5),
                backgroundBlendMode: BlendMode.overlay,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        isPlaying ? Icons.radio_button_checked_rounded : Icons.radio_rounded,
                        size: 48,
                        color: Color(0xFFB0B0B0), // Monochrome light grey for radio icon
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Prevents unbounded height error
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                            child: Text(
                              isPlaying ? "Menemani harimu..." : "Putar playlist untuk aktivitasmu",
                              key: ValueKey<bool>(isPlaying),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'Montserrat',
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(blurRadius: 6, color: Colors.black38),
                                    ],
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Additional row for artist and subtitle
                          Flexible(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Artist Name', // Replace with dynamic artist name
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontFamily: 'Montserrat',
                                          color: Color(0xFFD1D1D1),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFD1D1D1),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Subtitle or Info', // Replace with dynamic subtitle or info
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontFamily: 'Montserrat',
                                          color: Color(0xFFD1D1D1),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    isLoading
                        ? const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                            ),
                          )
                        : IconButton(
                            iconSize: 48,
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Icon(
                                isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_filled_rounded,
                                key: ValueKey<bool>(isPlaying),
                                color: Color(0xFFB0B0B0), // Monochrome light grey for play/stop icon
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                            tooltip: isPlaying ? 'Stop' : 'Play',
                            onPressed: () {
                              final cubit = context.read<RadioCubit>();
                              if (isPlaying) {
                                cubit.stopRadio();
                              } else {
                                cubit.playRadio('santai');
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}