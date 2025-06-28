// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/home/cubit/home_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Ganti 'fetchJournals()' menjadi 'watchJournals()'
      create: (context) => getIt<HomeCubit>()..watchJournals(), 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Beranda'),
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            // Tampilkan UI berdasarkan status
            switch (state.status) {
              case HomeStatus.loading:
              case HomeStatus.initial:
                return const Center(child: CircularProgressIndicator());
              case HomeStatus.failure:
                return Center(child: Text(state.errorMessage ?? 'Terjadi kesalahan'));
              case HomeStatus.success:
                if (state.journals.isEmpty) {
                  return const Center(child: Text('Belum ada jurnal.'));
                }
                // Tampilkan daftar jurnal
                return ListView.builder(
                  itemCount: state.journals.length,
                  itemBuilder: (context, index) {
                    final journal = state.journals[index];
                    return ListTile(
                      title: Text(journal.title),
                      subtitle: Text(journal.mood),
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }
}