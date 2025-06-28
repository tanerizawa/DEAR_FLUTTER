// lib/domain/usecases/get_journals_usecase.dart

import 'package:dear_flutter/domain/entities/journal.dart';
import 'package:dear_flutter/domain/repositories/journal_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetJournalsUseCase {
  final JournalRepository _repository;

  GetJournalsUseCase(this._repository);

  // Use case ini akan mengembalikan Stream, sehingga UI akan otomatis update
  // setiap kali ada perubahan di database.
  Stream<List<Journal>> call() {
    return _repository.getJournals();
  }
}