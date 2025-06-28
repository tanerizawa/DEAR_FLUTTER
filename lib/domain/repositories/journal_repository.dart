// lib/domain/repositories/journal_repository.dart

import 'package:dear_flutter/domain/entities/journal.dart';
import 'package:dear_flutter/data/models/requests.dart';

abstract class JournalRepository {
  /// Returns a stream of all [Journal]s. The stream should emit a new value
  /// whenever the underlying data changes.
  Stream<List<Journal>> getJournals();

  Future<Journal> createJournal(CreateJournalRequest request);
}