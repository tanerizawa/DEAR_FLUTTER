// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart';
import 'package:dear_flutter/presentation/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _onRefresh(BuildContext context) async {
    await context.read<HomeFeedCubit>().refreshHomeFeed();
    // Trigger refresh lagu baru dan langsung play (exclude radio)
    try {
      final musicCubit = getIt<LatestMusicCubit>();
      await musicCubit.refreshMusicAndPlay(context);
    } catch (e) {
      debugPrint('Gagal refresh dan play lagu baru: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeFeedCubit(getIt(), getIt(), getIt())..fetchHomeFeed(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFF191414), // Spotify dark background
          appBar: AppBar(
            backgroundColor: const Color(0xFF191414),
            elevation: 0,
            title: const Text(
              '',
              style: TextStyle(
                color: Color(0xFF1DB954), // Spotify green
                fontWeight: FontWeight.bold,
                fontSize: 28,
                letterSpacing: -1.5,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          body: RefreshIndicator(
            color: const Color(0xFF1DB954),
            onRefresh: () => _onRefresh(context),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              children: [
                // 1. Bagian Kutipan
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: const QuoteSection(),
                ),
                // 2. Bagian "Lagu Perasaan" (Player Tunggal)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: const MusicSection(),
                ),
                const SizedBox(height: 32),
                // 3. Judul untuk bagian radio
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Text(
                    '',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                // 4. Satu Kartu Radio
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: const RadioSection(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}