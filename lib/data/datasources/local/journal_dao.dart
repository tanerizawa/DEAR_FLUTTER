// Lokasi file: lib/data/datasources/local/journal_dao.dart

import 'package:dear_flutter/data/datasources/local/app_database.dart'; // File ini akan kita buat setelah ini
import 'package:dear_flutter/data/models/tables.dart';
import 'package:drift/drift.dart';

part 'journal_dao.g.dart'; // Jangan khawatir jika ada error di sini, akan hilang nanti

@DriftAccessor(tables: [JournalEntries])
class JournalDao extends DatabaseAccessor<AppDatabase> with _$JournalDaoMixin {
  JournalDao(super.db);

  Stream<List<JournalEntry>> watchAllJournals() =>
      (select(journalEntries)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).watch();

  Future<List<JournalEntry>> getAllJournals() =>
      (select(journalEntries)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).get();

  Stream<JournalEntry?> watchJournalById(int id) =>
      (select(journalEntries)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();

  Future<void> insertJournal(JournalEntry journal) =>
      into(journalEntries).insert(journal, mode: InsertMode.replace);

  Future<void> deleteJournalById(int id) =>
      (delete(journalEntries)..where((tbl) => tbl.id.equals(id))).go();

  Future<void> deleteAllJournals() =>
      delete(journalEntries).go();
}
