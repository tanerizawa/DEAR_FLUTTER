import 'package:dear_flutter/data/models/requests.dart';
import 'package:dear_flutter/domain/repositories/journal_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SaveJournalUseCase {
  final JournalRepository _repository;

  SaveJournalUseCase(this._repository);

  Future<void> call(CreateJournalRequest request) {
    // Logikanya nanti akan lebih kompleks (menyimpan ke API & lokal)
    // Untuk sekarang, kita hanya akan memanggil createJournal di repo
    return _repository.createJournal(request);
  }
}