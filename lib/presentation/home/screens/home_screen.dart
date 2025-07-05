// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _onRefresh(BuildContext context) async {
    try {
      // Trigger refresh home feed dan play lagu baru (semua di HomeFeedCubit)
      await context.read<HomeFeedCubit>().refreshHomeFeed();
    } catch (e) {
      debugPrint('Gagal refresh home feed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal refresh home feed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Asumsikan HomeFeedCubit sudah di-provide dari parent (MultiBlocProvider di root)
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: const Color(0xFF232526), // Monochrome dark background
        body: RefreshIndicator(
          color: const Color(0xFF1DB954),
          onRefresh: () => _onRefresh(context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              //   child: Text(
              //     'Radio',
              //     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              //           color: Colors.white,
              //           fontWeight: FontWeight.bold,
              //           fontFamily: 'Montserrat',
              //         ),
              //   ),
              // ),
              // const SizedBox(height: 16),
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
    );
  }
}