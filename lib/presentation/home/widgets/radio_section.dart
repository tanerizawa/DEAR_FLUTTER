// lib/presentation/home/widgets/radio_section.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/core/theme/mood_color_system.dart';
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
          
          // Get calm mood theme for radio
          final moodTheme = MoodColorSystem.getMoodTheme('tenang');
          final primaryColor = moodTheme['primary'] as Color;
          final gradientColors = moodTheme['gradient'] as List<Color>;

          return Container(
            // Golden ratio height: 89dp (cardHeightSecondary)
            height: MoodColorSystem.cardHeightSecondary,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(MoodColorSystem.space_md),
              gradient: LinearGradient(
                colors: [
                  MoodColorSystem.surfaceContainer,
                  primaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: MoodColorSystem.space_md,
                  offset: const Offset(0, MoodColorSystem.space_sm),
                ),
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: MoodColorSystem.space_sm,
                  offset: const Offset(0, MoodColorSystem.space_xs),
                ),
              ],
              border: Border.all(
                color: primaryColor.withOpacity(0.3), 
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(MoodColorSystem.space_md),
              child: Row(
                children: [
                  // Radio icon with golden ratio sizing
                  Container(
                    width: MoodColorSystem.space_2xl, // 55dp
                    height: MoodColorSystem.space_2xl, // 55dp
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          blurRadius: MoodColorSystem.space_sm,
                          offset: const Offset(0, MoodColorSystem.space_xs),
                        ),
                      ],
                    ),
                    child: Icon(
                      isPlaying ? Icons.radio_button_checked_rounded : Icons.radio_rounded,
                      size: MoodColorSystem.space_lg, // 34dp
                      color: MoodColorSystem.onSurface,
                    ),
                  ),
                  
                  const SizedBox(width: MoodColorSystem.space_sm),
                  
                  // Radio info with proper typography
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, animation) => 
                              FadeTransition(opacity: animation, child: child),
                          child: Text(
                            isPlaying ? "Menemani harimu..." : "Putar playlist untuk aktivitasmu",
                            key: ValueKey<bool>(isPlaying),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: MoodColorSystem.onSurface,
                              fontSize: MoodColorSystem.text_lg, // 20sp
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        const SizedBox(height: MoodColorSystem.space_xs),
                        
                        // Subtitle with mood color
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Radio Santai',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: primaryColor,
                                  fontSize: MoodColorSystem.text_base, // 16sp
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.symmetric(
                                horizontal: MoodColorSystem.space_xs,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Musik untuk relaksasi',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: MoodColorSystem.onSurfaceSecondary,
                                  fontSize: MoodColorSystem.text_base, // 16sp
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: MoodColorSystem.space_sm),
                  
                  // Play/Stop button with golden ratio sizing
                  SizedBox(
                    width: MoodColorSystem.space_2xl, // 55dp
                    height: MoodColorSystem.space_2xl, // 55dp
                    child: isLoading
                        ? CircularProgressIndicator(
                            strokeWidth: 3.0,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          )
                        : IconButton(
                            iconSize: MoodColorSystem.space_lg, // 34dp
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Icon(
                                isPlaying 
                                    ? Icons.pause_circle_filled_rounded 
                                    : Icons.play_circle_filled_rounded,
                                key: ValueKey<bool>(isPlaying),
                                color: primaryColor,
                              ),
                            ),
                            tooltip: isPlaying ? 'Pause' : 'Play',
                            onPressed: () {
                              final cubit = context.read<RadioCubit>();
                              if (isPlaying) {
                                cubit.stopRadio();
                              } else {
                                cubit.playRadio('santai');
                              }
                            },
                          ),
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