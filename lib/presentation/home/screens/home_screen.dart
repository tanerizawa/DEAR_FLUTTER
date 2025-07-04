// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- PERBAIKAN: Menambahkan import yang hilang ---
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _onRefresh(BuildContext context) async {
    await context.read<HomeFeedCubit>().fetchHomeFeed();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeFeedCubit(getIt())..fetchHomeFeed(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Beranda'),
        ),
        body: BlocBuilder<HomeFeedCubit, HomeFeedState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => _onRefresh(context),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  QuoteSection(),
                  SizedBox(height: 24),
                  MusicSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}