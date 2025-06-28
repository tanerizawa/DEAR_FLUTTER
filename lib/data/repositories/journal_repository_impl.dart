// lib/data/repositories/journal_repository_impl.dart

import 'package:dear_flutter/data/datasources/local/app_database.dart';
import 'package:dear_flutter/data/datasources/local/journal_dao.dart';
import 'package:dear_flutter/domain/entities/journal.dart';
import 'package:dear_flutter/domain/repositories/journal_repository.dart';
import 'package:dear_flutter/data/datasources/remote/journal_api_service.dart';
import 'package:dear_flutter/data/models/requests.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: JournalRepository) // <-- PASTIKAN BARIS INI ADA
class JournalRepositoryImpl implements JournalRepository {
  final JournalApiService _apiService;
  final JournalDao _journalDao;

  JournalRepositoryImpl(this._apiService, this._journalDao);

  // --- MAPPERS ---
  // Fungsi untuk mengubah dari format Database ke format Domain
  Journal _mapJournalEntryToDomain(JournalEntry entry) {
    return Journal(
      id: entry.id,
      title: entry.title,
      content: entry.content,
      mood: entry.mood,
      createdAt: entry.createdAt,
    );
  }

  @override
  Stream<List<Journal>> getJournals() {
    // Panggil DAO, lalu ubah (map) setiap list yang datang
    // dari format database ke format domain.
    return _journalDao
        .watchAllJournals()
        .map((entries) => entries.map(_mapJournalEntryToDomain).toList());
  }

  @override
  Future<Journal> createJournal(CreateJournalRequest request) async {
    final newJournal = await _apiService.createJournal(request);
    // TODO: Simpan newJournal ke database lokal setelah dibuat.
    return newJournal;
  }
}