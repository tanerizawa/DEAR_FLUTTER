// lib/domain/repositories/journal_repository.dart

import 'package:dear_flutter/domain/entities/journal.dart';
import 'package:dear_flutter/data/models/requests.dart';

abstract class JournalRepository {
  Future<List<Journal>> getJournals();
  
  Future<Journal> createJournal(CreateJournalRequest request);
}