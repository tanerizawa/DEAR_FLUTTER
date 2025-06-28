import 'package:freezed_annotation/freezed_annotation.dart';

part 'journal_editor_state.freezed.dart';

enum JournalEditorStatus { initial, loading, success, failure }

@freezed
class JournalEditorState with _$JournalEditorState {
  const factory JournalEditorState({
    @Default(JournalEditorStatus.initial) JournalEditorStatus status,
    String? errorMessage,
  }) = _JournalEditorState;
}