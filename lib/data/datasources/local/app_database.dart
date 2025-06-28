// lib/data/datasources/local/app_database.dart

import 'dart:io';
import 'package:dear_flutter/data/datasources/local/journal_dao.dart';
import 'package:dear_flutter/data/models/tables.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [JournalEntries, ChatMessages], daos: [JournalDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;
}

LazyDatabase _openConnection() {
  return LazyDatabase(
    () async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase(file);
    },
  );
}

// PASTIKAN KELAS DatabaseModule DI BAWAH INI SUDAH DIHAPUS