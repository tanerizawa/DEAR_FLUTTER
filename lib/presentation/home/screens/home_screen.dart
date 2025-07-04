// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _onRefresh(BuildContext context) async {
    await context.read<HomeFeedCubit>().fetchHomeFeed();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeFeedCubit(getIt(), getIt())..fetchHomeFeed(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Beranda'),
        ),
        body: BlocBuilder<HomeFeedCubit, HomeFeedState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => _onRefresh(context),
              child: _buildLayoutForState(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLayoutForState(BuildContext context, HomeFeedState state) {
    if (state.status == HomeFeedStatus.loading && state.feed == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == HomeFeedStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            state.errorMessage ?? 'Terjadi kesalahan. Tarik ke bawah untuk mencoba lagi.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final mood = state.lastMood?.toLowerCase();
    if (mood == 'sad' || mood == 'angry' || mood == 'bad' || mood == 'lelah') {
      return _CalmLayout();
    } 
    else if (mood == 'happy' || mood == 'good' || mood == 'great' || mood == 'semangat') {
      return _EnergeticLayout();
    } 
    else {
      return _DefaultLayout();
    }
  }
}

class _DefaultLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: const [
        QuoteSection(),
        SizedBox(height: 24),
        MusicSection(),
      ],
    );
  }
}

class _CalmLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Text("Semoga ini bisa menenangkanmu...", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          // --- PERBAIKAN: Mengganti withOpacity ---
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(30), // alpha 30 ~ 12% opacity
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: QuoteSection(),
          ),
        ),
        const SizedBox(height: 32),
        const MusicSection(),
      ],
    );
  }
}

class _EnergeticLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Text("Musik untuk harimu yang ceria!", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const MusicSection(),
        const SizedBox(height: 24),
        const QuoteSection(),
      ],
    );
  }
}