// Lokasi file: lib/data/models/tables.dart

import 'package:drift/drift.dart';

// Tabel ini adalah padanan dari JournalEntity.kt
class JournalEntries extends Table {
  // Kolom-kolomnya
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get mood => text()();
  RealColumn get sentimentScore => real().nullable()();
  TextColumn get sentimentLabel => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean()();

  // Menetapkan 'id' sebagai Primary Key
  @override
  Set<Column> get primaryKey => {id};
}


// Tabel ini adalah padanan dari ChatMessageEntity.kt
@DataClassName('ChatMessageEntity') // Nama kelas data yang akan dibuat
class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get emotion => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isFlagged => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
