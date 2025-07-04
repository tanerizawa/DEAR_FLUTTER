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
      // --- PERBAIKAN UTAMA DI SINI ---
      // Tambahkan getIt() ketiga untuk AudioUrlCacheService
      create: (_) => HomeFeedCubit(getIt(), getIt(), getIt())..fetchHomeFeed(),
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

  /// Fungsi helper untuk memilih dan membangun layout yang benar berdasarkan state.
  Widget _buildLayoutForState(BuildContext context, HomeFeedState state) {
    // 1. Tampilkan loading indicator saat aplikasi pertama kali dibuka
    if (state.status == HomeFeedStatus.loading && state.feed == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Tampilkan pesan error jika terjadi kegagalan
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

    // 3. Tentukan layout berdasarkan mood terakhir
    final mood = state.lastMood?.toLowerCase();

    // Layout untuk mood negatif (fokus ke kutipan yang menenangkan)
    if (mood == 'sad' || mood == 'angry' || mood == 'bad' || mood == 'lelah') {
      return _CalmLayout();
    }
    // Layout untuk mood positif (fokus ke musik yang ceria)
    else if (mood == 'happy' || mood == 'good' || mood == 'great' || mood == 'semangat') {
      return _EnergeticLayout();
    }
    // Layout default untuk mood netral atau jika tidak ada mood
    else {
      return _DefaultLayout();
    }
  }
}

// --- DEFINISI WIDGET-WIDGET LAYOUT ---

/// Layout Standar: Kutipan di atas, Musik di bawah.
class _DefaultLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(), // Memastikan refresh selalu bisa
      padding: const EdgeInsets.all(16),
      children: const [
        QuoteSection(),
        SizedBox(height: 24),
        MusicSection(),
      ],
    );
  }
}

/// Layout Tenang: Menonjolkan kutipan untuk memberikan ketenangan.
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
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(30),
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

/// Layout Energik: Musik ditampilkan lebih dulu untuk menambah semangat.
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