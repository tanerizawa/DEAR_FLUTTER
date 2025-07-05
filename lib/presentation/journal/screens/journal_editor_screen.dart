import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/data/repositories/journal_repository.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';
import 'package:dear_flutter/presentation/journal/cubit/journal_editor_cubit.dart';
import 'package:dear_flutter/presentation/journal/cubit/journal_editor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JournalEditorScreen extends StatefulWidget {
  final JournalEntry? initialEntry;
  const JournalEditorScreen({Key? key, this.initialEntry}) : super(key: key);

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
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
  bool _showSuccess = false;
  bool _isSaving = false;

  String get _selectedEmoji => _selectedMood.split(' ').last;
  String get _selectedLabel => _selectedMood.split(' ').first;

  bool get _isContentValid =>
      _contentController.text.trim().isNotEmpty &&
      _contentController.text.trim().length <= 500;

  @override
  void initState() {
    super.initState();
    if (widget.initialEntry != null) {
      _contentController.text = widget.initialEntry!.content;
      _selectedMood = widget.initialEntry!.mood;
    } else {
      _restoreDraftIfAny();
    }
  }

  @override
  void dispose() {
    _saveDraftIfNeeded();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _saveDraftIfNeeded() {
    if (_contentController.text.trim().isNotEmpty && !_showSuccess) {
      // Simpan draft ke SharedPreferences (atau storage lokal lain)
      // Key: 'journal_draft', Value: content + mood
      // Implementasi sederhana, bisa diimprove ke Hive jika perlu
      final draft = {
        'content': _contentController.text,
        'mood': _selectedMood,
      };
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('journal_draft', jsonEncode(draft));
      });
    }
  }

  void _deleteDraft() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('journal_draft');
  }

  void _restoreDraftIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final draftStr = prefs.getString('journal_draft');
    if (draftStr != null) {
      final draft = jsonDecode(draftStr);
      if (draft['content'] != null && draft['content'].toString().trim().isNotEmpty) {
        setState(() {
          _contentController.text = draft['content'];
          _selectedMood = draft['mood'] ?? 'Netral 😐';
        });
        // Show notification/snackbar if draft is restored
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Draft dipulihkan')),
            );
          }
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_contentController.text.trim().isEmpty) return true;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batal menulis?'),
        content: const Text('Perubahan jurnal belum disimpan. Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Lanjutkan Menulis'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  void _onSuccess() async {
    setState(() => _showSuccess = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 900));
    _deleteDraft();
    if (mounted) {
      Navigator.of(context).pop('refresh'); // Kirim sinyal refresh ke list
    }
  }

  Future<void> _saveJournal() async {
    if (_isSaving || !_isContentValid) return;
    setState(() => _isSaving = true);
    try {
      final entry = JournalEntry(
        id: widget.initialEntry?.id,
        date: widget.initialEntry?.date ?? DateTime.now(),
        mood: _selectedMood,
        content: _contentController.text.trim(),
      );
      if (widget.initialEntry != null) {
        await JournalRepository().update(entry);
      } else {
        await JournalRepository().add(entry);
      }
      _onSuccess();
    } catch (e, s) {
      debugPrint('Gagal simpan jurnal: $e\n$s');
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Gagal menyimpan jurnal: $e')),
        );
    }
  }

  Color _moodColor(String mood) {
    if (mood.contains('Senang')) return const Color(0xFFFFD600);
    if (mood.contains('Sedih')) return const Color(0xFF64B5F6);
    if (mood.contains('Marah')) return const Color(0xFFE57373);
    if (mood.contains('Cemas')) return const Color(0xFFFFB300);
    if (mood.contains('Netral')) return const Color(0xFFB4B8C5);
    if (mood.contains('Bersyukur')) return const Color(0xFF81C784);
    if (mood.contains('Bangga')) return const Color(0xFFBA68C8);
    if (mood.contains('Takut')) return const Color(0xFF90A4AE);
    if (mood.contains('Kecewa')) return const Color(0xFF8D6E63);
    return const Color(0xFFB4B8C5);
  }

  @override
  Widget build(BuildContext context) {
    // Define warna konsisten dengan Home
    const bgColor = Color(0xFF232526); // dark
    const cardColor = Color(0xFF2C2F34); // dark card
    const textColor = Colors.white;
    const accentTextColor = Color(0xFFB4B8C5);

    return BlocProvider(
      create: (context) => getIt<JournalEditorCubit>(),
      child: BlocListener<JournalEditorCubit, JournalEditorState>(
        listener: (context, state) {
          if (state.status == JournalEditorStatus.success) {
            _onSuccess();
          }
          if (state.status == JournalEditorStatus.failure) {
            setState(() => _showSuccess = false);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Terjadi kesalahan')),
              );
          }
        },
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: const Text('Tulis Jurnal'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: textColor,
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 90),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Mood picker horizontal minimalis dengan highlight/gradient
                          SizedBox(
                            height: 70,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _moods.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 14),
                              itemBuilder: (context, i) {
                                final mood = _moods[i];
                                final emoji = mood.split(' ').last;
                                final selected = _selectedMood == mood;
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() => _selectedMood = mood);
                                    Future.delayed(const Duration(milliseconds: 100), () {
                                      if (mounted) _contentFocusNode.requestFocus();
                                    });
                                  },
                                  onLongPress: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(mood)),
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOut,
                                    width: selected ? 58 : 48,
                                    height: selected ? 58 : 48,
                                    decoration: BoxDecoration(
                                      gradient: selected
                                          ? LinearGradient(colors: [
                                              _moodColor(mood).withOpacity(0.7),
                                              Colors.white.withOpacity(0.2)
                                            ])
                                          : null,
                                      color: selected ? null : cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: selected ? Border.all(color: _moodColor(mood), width: 2) : null,
                                      boxShadow: selected
                                          ? [BoxShadow(color: _moodColor(mood).withOpacity(0.18), blurRadius: 8, spreadRadius: 1)]
                                          : [],
                                    ),
                                    child: Center(
                                      child: Text(
                                        emoji,
                                        style: TextStyle(fontSize: selected ? 32 : 26),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Scroll indicator shadow
                          Container(
                            height: 4,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  Color(0x22000000),
                                  Colors.transparent
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Label mood besar hanya saat dipilih
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  _selectedMood.split(' ').last,
                                  style: const TextStyle(fontSize: 44),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedMood.split(' ').first,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: _moodColor(_selectedMood),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Input jurnal minimalis dengan animasi border
                          Semantics(
                            label: 'Isi jurnal',
                            textField: true,
                            child: Focus(
                              onFocusChange: (hasFocus) => setState(() {}),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    TextField(
                                      controller: _contentController,
                                      focusNode: _contentFocusNode,
                                      decoration: InputDecoration(
                                        hintText: 'Ceritakan harimu di sini…',
                                        filled: true,
                                        fillColor: cardColor,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(color: _moodColor(_selectedMood), width: 2),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                      ),
                                      style: TextStyle(fontSize: 16, color: textColor),
                                      maxLines: null,
                                      minLines: 6,
                                      onChanged: (_) => setState(() {}),
                                    ),
                                    // Counter karakter sebagai watermark
                                    Positioned(
                                      right: 16,
                                      bottom: 10,
                                      child: Text(
                                        "${_contentController.text.length}/500",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _contentController.text.length > 500 ? Colors.red : accentTextColor.withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  // Sticky Save Button minimalis dengan warna mood dan animasi loading
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: Semantics(
                            label: _showSuccess
                                ? 'Jurnal berhasil disimpan'
                                : (_isSaving
                                    ? 'Menyimpan jurnal'
                                    : 'Simpan jurnal'),
                            button: true,
                            enabled: !_showSuccess && !_isSaving,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              child: _showSuccess
                                  ? Container(
                                      key: const ValueKey('success'),
                                      decoration: BoxDecoration(
                                        color: _moodColor(_selectedMood),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _moodColor(_selectedMood).withOpacity(0.18),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 32),
                                      ),
                                    )
                                  : Stack(
                                      children: [
                                        ElevatedButton(
                                          key: const ValueKey('button'),
                                          child: _isSaving
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                                )
                                              : const Text('Simpan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _isSaving || _showSuccess
                                                ? _moodColor(_selectedMood).withOpacity(0.5)
                                                : _moodColor(_selectedMood),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            elevation: 2,
                                            shadowColor: _moodColor(_selectedMood).withOpacity(0.18),
                                          ),
                                          onPressed: _isSaving || _showSuccess || !_isContentValid
                                              ? null
                                              : _saveJournal,
                                        ),
                                        if (_isSaving)
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: LinearProgressIndicator(
                                              minHeight: 3,
                                              backgroundColor: Colors.transparent,
                                              color: _moodColor(_selectedMood),
                                            ),
                                          ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Feedback sukses overlay
                  if (_showSuccess)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: _showSuccess ? 1 : 0,
                          duration: const Duration(milliseconds: 400),
                          child: Container(
                            color: Colors.black.withOpacity(0.18),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 64),
                                  SizedBox(height: 12),
                                  Text('Jurnal tersimpan!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
