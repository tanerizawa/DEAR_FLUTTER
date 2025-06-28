// lib/domain/repositories/journal_repository.dart

import 'package:dear_flutter/data/models/requests.dart';
import 'package:dear_flutter/domain/entities/journal.dart';

// File ini HANYA boleh berisi abstract class ini.
abstract class JournalRepository {
  Stream<List<Journal>> getJournals();
  Future<void> createJournal(CreateJournalRequest request);
  Future<void> syncJournals(); // <-- TAMBAHKAN INI
}
