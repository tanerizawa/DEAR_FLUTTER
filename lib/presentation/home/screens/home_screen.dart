// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const goldenRatio = 1.618;

    return BlocProvider(
      create: (context) => getIt<HomeFeedCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Beranda'),
        ),
        body: BlocBuilder<HomeFeedCubit, HomeFeedState>(
          builder: (context, state) {
            if (state.status == HomeFeedStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == HomeFeedStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? 'Terjadi kesalahan'),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Selamat datang!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ...state.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _HomeFeedCard(
                      item: item,
                      height: screenHeight / goldenRatio,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeFeedCard extends StatelessWidget {
  const _HomeFeedCard({required this.item, required this.height});

  final HomeFeedItem item;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: item.when(
            article: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Artikel'),
                Text(data.title),
              ],
            ),
            audio: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Musik'),
                Text(data.title),
              ],
            ),
            quote: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quote'),
                Text('"${data.text}" - ${data.author}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
