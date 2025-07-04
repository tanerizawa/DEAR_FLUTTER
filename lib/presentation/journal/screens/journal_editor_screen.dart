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
  final _contentController = TextEditingController();
  String _selectedMood = 'Netral 😐';
  final List<String> _moods = [
    'Senang 😊',
    'Sedih 😢',
    'Marah 😡',
    'Cemas 😰',
    'Netral 😐',
    'Bersyukur 🙏',
    'Bangga 😎',
    'Takut 😱',
    'Kecewa 😞',
  ];

  String get _selectedEmoji => _selectedMood.split(' ').last;
  String get _selectedLabel => _selectedMood.split(' ').first;

  @override
  void dispose() {
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
            context.go('/home');
          }
          if (state.status == JournalEditorStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Terjadi kesalahan')),
              );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Tulis Jurnal'),
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bagaimana perasaanmu hari ini?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Mood picker ala Moodflow
                SizedBox(
                  height: 80,
                  child: GridView.count(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _moods.map((mood) {
                      final emoji = mood.split(' ').last;
                      final label = mood.split(' ').first;
                      final selected = _selectedMood == mood;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMood = mood),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: selected ? Colors.blue.shade100 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: selected ? Border.all(color: Colors.blue, width: 2) : null,
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: TextStyle(fontSize: selected ? 32 : 26),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _selectedLabel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Input jurnal
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      hintText: 'Tulis apapun yang kamu rasakan hari ini...'
                          '\nContoh: Aku merasa lebih baik setelah jalan-jalan.',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    style: const TextStyle(fontSize: 16),
                    maxLines: null,
                    expands: true,
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<JournalEditorCubit, JournalEditorState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: state.status == JournalEditorStatus.loading
                            ? null
                            : () {
                                context.read<JournalEditorCubit>().saveJournal(
                                      title: '',
                                      content: _contentController.text,
                                      mood: _selectedMood,
                                    );
                              },
                        child: state.status == JournalEditorStatus.loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Simpan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
