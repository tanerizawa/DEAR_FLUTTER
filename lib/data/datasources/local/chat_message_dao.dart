import 'package:dear_flutter/data/datasources/local/app_database.dart';
import 'package:dear_flutter/data/models/tables.dart';
import 'package:drift/drift.dart';

part 'chat_message_dao.g.dart';

@DriftAccessor(tables: [ChatMessages])
class ChatMessageDao extends DatabaseAccessor<AppDatabase> with _$ChatMessageDaoMixin {
  ChatMessageDao(super.db);

  // Mengambil semua pesan, diurutkan berdasarkan waktu
  Stream<List<ChatMessageEntity>> watchAllMessages() =>
      (select(chatMessages)..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.asc)])).watch();

  // Memasukkan pesan baru
  Future<void> insertMessage(ChatMessageEntity message) =>
      into(chatMessages).insert(message, mode: InsertMode.replace);

  // Menghapus pesan berdasarkan ID
  Future<void> deleteMessageById(String id) =>
      (delete(chatMessages)..where((tbl) => tbl.id.equals(id))).go();
}
