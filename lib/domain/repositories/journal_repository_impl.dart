// lib/data/repositories/journal_repository_impl.dart

import 'package:dear_flutter/domain/entities/journal.dart';
import 'package:dear_flutter/domain/repositories/journal_repository.dart';
import 'package:dear_flutter/data/datasources/remote/journal_api_service.dart';
import 'package:dear_flutter/data/models/requests.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: JournalRepository) // Mendaftarkan kelas ini sebagai implementasi dari JournalRepository
class JournalRepositoryImpl implements JournalRepository {
  final JournalApiService _journalApiService;

  JournalRepositoryImpl(this._journalApiService); // Dependencies akan di-inject secara otomatis

  @override
  Future<List<Journal>> getJournals() {
    // Cukup teruskan panggilan ke API service
    return _journalApiService.getJournals();
  }

  @override
  Future<Journal> createJournal(CreateJournalRequest request) {
    return _journalApiService.createJournal(request);
  }
}