import 'package:dear_flutter/domain/repositories/journal_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SyncJournalsUseCase {
  final JournalRepository _repository;

  SyncJournalsUseCase(this._repository);

  // Kita akan mengembalikan Future<void> karena tugas ini tidak langsung
  // mengembalikan data ke UI, hanya memicu proses di latar belakang.
  Future<void> call() {
    return _repository.syncJournals();
  }
}