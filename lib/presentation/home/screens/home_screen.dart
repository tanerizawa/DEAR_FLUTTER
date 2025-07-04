// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart'; // <-- HAPUS IMPORT INI

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _onRefresh(BuildContext context) async {
    await context.read<HomeFeedCubit>().refreshHomeFeed();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeFeedCubit(getIt(), getIt())..fetchHomeFeed(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Beranda'),
        ),
        body: RefreshIndicator(
          onRefresh: () => _onRefresh(context),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const QuoteSection(),
              const SizedBox(height: 24),
              const MusicSection(),
              const SizedBox(height: 32),
              Text(
                'Temani Aktivitasmu',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              // Tambahkan const untuk performa
              const RadioSection(
                title: 'Radio Fokus',
                category: 'fokus',
                icon: Icons.work_outline_rounded,
              ),
              const SizedBox(height: 12),
              const RadioSection(
                title: 'Musik Santai',
                category: 'santai',
                icon: Icons.self_improvement_rounded,
              ),
              const SizedBox(height: 12),
              const RadioSection(
                title: 'Pembangkit Semangat',
                category: 'semangat',
                icon: Icons.local_fire_department_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}