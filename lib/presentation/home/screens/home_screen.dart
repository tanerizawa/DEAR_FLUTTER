// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _onRefresh(BuildContext context) async {
    await context.read<HomeFeedCubit>().refreshHomeFeed();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeFeedCubit(getIt(), getIt(), getIt())..fetchHomeFeed(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Beranda'),
        ),
        body: RefreshIndicator(
          onRefresh: () => _onRefresh(context),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Bagian Kutipan
              const QuoteSection(),
              const SizedBox(height: 24),
              
              // 2. Bagian "Lagu Perasaan" (Player Tunggal)
              const MusicSection(),
              const SizedBox(height: 32),

              // 3. Judul untuk bagian radio
              Text(
                'Temani Aktivitasmu',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              // 4. Satu Kartu Radio
              const RadioSection(),
            ],
          ),
        ),
      ),
    );
  }
}