// lib/presentation/home/screens/home_screen.dart

import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/home/cubit/home_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_state.dart';
import 'package:dear_flutter/presentation/journal/screens/journal_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Beranda'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const JournalEditorScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            switch (state.status) {
              case HomeStatus.initial:
              case HomeStatus.loading:
                return const Center(child: CircularProgressIndicator());

              case HomeStatus.failure:
                return Center(
                  child: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                );

              case HomeStatus.success:
                if (state.journals.isEmpty) {
                  return const Center(child: Text('Belum ada jurnal.'));
                }
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
