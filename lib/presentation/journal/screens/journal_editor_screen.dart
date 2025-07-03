import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/presentation/journal/cubit/journal_editor_cubit.dart';
import 'package:dear_flutter/presentation/journal/cubit/journal_editor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class JournalEditorScreen extends StatefulWidget {
  const JournalEditorScreen({super.key});

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<JournalEditorCubit>(),
      child: BlocListener<JournalEditorCubit, JournalEditorState>(
        listener: (context, state) {
          if (state.status == JournalEditorStatus.success) {
            // Jika sukses, kembali ke halaman sebelumnya
            // Gunakan GoRouter untuk memastikan navigasi tidak memicu error
            // saat stack kosong
            context.go('/home');
          }
          if (state.status == JournalEditorStatus.failure) {
            // Jika gagal, tampilkan Snackbar
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Terjadi kesalahan')),
              );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Entri Baru'),
            actions: [
              // Tombol Simpan
              BlocBuilder<JournalEditorCubit, JournalEditorState>(
                builder: (context, state) {
                  if (state.status == JournalEditorStatus.loading) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
                    );
                  }
                  return TextButton(
                    onPressed: () {
                      context.read<JournalEditorCubit>().saveJournal(
                            title: _titleController.text,
                            content: _contentController.text,
                            mood: 'Netral', // Mood sementara
                          );
                    },
                    child: const Text('Simpan'),
                  );
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Apa yang kamu rasakan?',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null, // Memungkinkan banyak baris
                    expands: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
