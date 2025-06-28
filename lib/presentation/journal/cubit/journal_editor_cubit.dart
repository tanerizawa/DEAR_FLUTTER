import 'package:dear_flutter/data/models/requests.dart';
import 'package:dear_flutter/domain/usecases/save_journal_usecase.dart';
import 'package:dear_flutter/presentation/journal/cubit/journal_editor_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class JournalEditorCubit extends Cubit<JournalEditorState> {
  final SaveJournalUseCase _saveJournalUseCase;

  JournalEditorCubit(this._saveJournalUseCase) : super(const JournalEditorState());

  Future<void> saveJournal({
    required String title,
    required String content,
    required String mood,
  }) async {
    if (title.isEmpty || content.isEmpty) {
      emit(state.copyWith(
        status: JournalEditorStatus.failure,
        errorMessage: 'Judul dan konten tidak boleh kosong.',
      ));
      // Kembalikan ke state awal setelah menampilkan error
      emit(state.copyWith(status: JournalEditorStatus.initial, errorMessage: null));
      return;
    }

    emit(state.copyWith(status: JournalEditorStatus.loading));

    try {
      final request = CreateJournalRequest(title: title, content: content, mood: mood);
      await _saveJournalUseCase(request);
      emit(state.copyWith(status: JournalEditorStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: JournalEditorStatus.failure,
        errorMessage: 'Gagal menyimpan jurnal. Coba lagi.',
      ));
    }
  }
}
