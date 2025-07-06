import 'package:dear_flutter/data/repositories/journal_repository.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';

/// Utility to add sample journal entries for testing
class JournalTestData {
  static Future<void> addSampleEntries() async {
    final repository = JournalRepository();
    
    // Clear existing entries first
    await repository.clearAll();
    
    final now = DateTime.now();
    
    final sampleEntries = [
      JournalEntry(
        date: now,
        mood: 'Senang 😊',
        content: 'Hari ini sangat menyenangkan! Saya berhasil menyelesaikan proyek yang sudah lama tertunda. Rasanya lega sekali dan bangga dengan pencapaian ini. Weather juga cerah dan sempat jalan-jalan di taman.',
      ),
      JournalEntry(
        date: now.subtract(const Duration(days: 1)),
        mood: 'Sedih 😢',
        content: 'Kemarin agak berat rasanya. Ada beberapa hal yang tidak berjalan sesuai rencana dan membuat mood turun. Tapi sudah mulai membaik hari ini.',
      ),
      JournalEntry(
        date: now.subtract(const Duration(days: 2)),
        mood: 'Cemas 😰',
        content: 'Besok ada presentasi penting dan merasa agak nervous. Sudah persiapan sebaik mungkin tapi tetap ada perasaan was-was. Semoga semuanya berjalan lancar.',
      ),
      JournalEntry(
        date: now.subtract(const Duration(days: 3)),
        mood: 'Netral 😐',
        content: 'Hari biasa-biasa saja. Tidak ada yang istimewa terjadi. Rutinitas kerja seperti biasa, pulang tidur. Sometimes monoton tapi ya sudah biasa.',
      ),
      JournalEntry(
        date: now.subtract(const Duration(days: 5)),
        mood: 'Bangga 🤩',
        content: 'Achievement unlocked! Berhasil menyelesaikan challenge coding yang sulit. Butuh waktu berminggu-minggu tapi akhirnya berhasil juga. Merasa sangat bangga dengan effort yang sudah dikeluarkan.',
      ),
      JournalEntry(
        date: now.subtract(const Duration(days: 7)),
        mood: 'Bersyukur 🙏',
        content: 'Hari ini merasa sangat bersyukur. Ada banyak hal positif yang terjadi minggu ini. Keluarga sehat, pekerjaan lancar, dan bisa bertemu teman lama. Life is good!',
      ),
    ];
    
    for (final entry in sampleEntries) {
      await repository.add(entry);
      print('[TEST DATA] Added journal: ${entry.mood} - ${entry.content.substring(0, 30)}...');
    }
    
    print('[TEST DATA] Successfully added ${sampleEntries.length} sample journal entries');
  }
  
  static Future<void> printAllEntries() async {
    final repository = JournalRepository();
    final entries = await repository.getAll();
    
    print('[TEST DATA] Found ${entries.length} journal entries:');
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      print('[TEST DATA] $i. ${entry.date.toLocal().toString().split(' ')[0]} - ${entry.mood} - ${entry.content.substring(0, entry.content.length > 50 ? 50 : entry.content.length)}...');
    }
  }
}
