// lib/data/repositories/journal_repository_impl.dart

import 'package:dear_flutter/data/datasources/local/app_database.dart';
import 'package:dear_flutter/data/datasources/local/journal_dao.dart';
import 'package:dear_flutter/data/datasources/remote/journal_api_service.dart';
import 'package:dear_flutter/data/models/requests.dart';
import 'package:dear_flutter/domain/entities/journal.dart';
import 'package:dear_flutter/domain/repositories/journal_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: JournalRepository) // <-- INI PERBAIKANNYA
class JournalRepositoryImpl implements JournalRepository {
  final JournalApiService _apiService;
  final JournalDao _journalDao;

  JournalRepositoryImpl(this._apiService, this._journalDao);

  // ... (sisa kode mapper dan fungsi lainnya tetap sama)
  Journal _mapJournalEntryToDomain(JournalEntry entry) {
    return Journal(
        id: entry.id,
        title: entry.title,
        content: entry.content,
        mood: entry.mood,
        createdAt: entry.createdAt);
  }

  JournalEntry _mapDomainToJournalEntry(Journal journal) {
    return JournalEntry(
      id: journal.id,
      title: journal.title,
      content: journal.content,
      mood: journal.mood,
      createdAt: journal.createdAt,
      isSynced: true,
    );
  }

  @override
  Stream<List<Journal>> getJournals() {
    return _journalDao
        .watchAllJournals()
        .map((entries) => entries.map(_mapJournalEntryToDomain).toList());
  }

  @override
  Future<void> createJournal(CreateJournalRequest request) async {
    final newJournalFromServer = await _apiService.createJournal(request);
    await _journalDao.insertJournal(_mapDomainToJournalEntry(newJournalFromServer));
  }

  @override
  Future<void> syncJournals() async {
    final remoteJournals = await _apiService.getJournals();
    for (final journal in remoteJournals) {
      await _journalDao.insertJournal(_mapDomainToJournalEntry(journal));
    }
  }
}