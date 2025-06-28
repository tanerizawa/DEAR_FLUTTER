// lib/data/repositories/journal_repository_impl.dart

import 'package:dear_flutter/data/datasources/local/app_database.dart';
import 'package:dear_flutter/data/datasources/local/journal_dao.dart';
import 'package:dear_flutter/domain/entities/journal.dart';
import 'package:dear_flutter/domain/repositories/journal_repository.dart';
import 'package:dear_flutter/data/datasources/remote/journal_api_service.dart';
import 'package:dear_flutter/data/models/requests.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: JournalRepository)
class JournalRepositoryImpl implements JournalRepository {
  final JournalApiService _apiService;
  final JournalDao _journalDao;

  JournalRepositoryImpl(this._apiService, this._journalDao);

  // --- MAPPERS ---
  Journal _mapJournalEntryToDomain(JournalEntry entry) {
    return Journal(
        id: entry.id,
        title: entry.title,
        content: entry.content,
        mood: entry.mood,
        createdAt: entry.createdAt);
  }

  // Mapper untuk mengubah dari format API (domain) ke format Database
  JournalEntry _mapDomainToJournalEntry(Journal journal) {
    return JournalEntry(
      id: journal.id,
      title: journal.title,
      content: journal.content,
      mood: journal.mood,
      createdAt: journal.createdAt,
      isSynced: true, // Asumsikan data dari API sudah tersinkronisasi
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
    try {
      // 1. Panggil API untuk membuat jurnal baru di server
      final newJournalFromServer = await _apiService.createJournal(request);
      // 2. Simpan jurnal yang baru dibuat ke database lokal
      await _journalDao.insertJournal(_mapDomainToJournalEntry(newJournalFromServer));
    } catch (e) {
      // Tangani error jika gagal (misalnya, tidak ada koneksi internet)
      print('Gagal membuat jurnal: $e');
      // Di aplikasi nyata, kita bisa menyimpan ke lokal dulu dengan flag isSynced = false
      rethrow;
    }
  }

  @override
  Future<void> syncJournals() async {
    try {
      // 1. Ambil semua jurnal dari server
      final remoteJournals = await _apiService.getJournals();
      // 2. Simpan setiap jurnal ke database lokal
      for (final journal in remoteJournals) {
        await _journalDao.insertJournal(_mapDomainToJournalEntry(journal));
      }
    } catch (e) {
      print('Gagal sinkronisasi: $e');
      rethrow;
    }
  }
}