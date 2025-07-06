import 'package:flutter_test/flutter_test.dart';
import 'package:dear_flutter/data/repositories/journal_repository.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Journal Repository Tests', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and retrieve journal entries', () async {
      final repository = JournalRepository();
      
      // Create test entries
      final entry1 = JournalEntry(
        date: DateTime.now(),
        mood: 'Senang 😊',
        content: 'Test journal entry 1 - Hari ini sangat menyenangkan!',
      );
      
      final entry2 = JournalEntry(
        date: DateTime.now().subtract(const Duration(days: 1)),
        mood: 'Sedih 😢',
        content: 'Test journal entry 2 - Kemarin agak berat.',
      );

      // Add entries
      await repository.add(entry1);
      await repository.add(entry2);

      // Retrieve entries
      final journals = await repository.getAll();

      // Verify
      expect(journals.length, 2);
      expect(journals.any((j) => j.content.contains('sangat menyenangkan')), true);
      expect(journals.any((j) => j.content.contains('agak berat')), true);
      
      print('Test passed: Repository can save and retrieve ${journals.length} journal entries');
      for (var journal in journals) {
        print('Journal: ${journal.mood} - ${journal.content}');
      }
    });

    test('should handle empty repository', () async {
      final repository = JournalRepository();
      final journals = await repository.getAll();
      
      expect(journals, isEmpty);
      print('Test passed: Empty repository returns empty list');
    });

    test('should update existing entries', () async {
      final repository = JournalRepository();
      
      final originalEntry = JournalEntry(
        date: DateTime.now(),
        mood: 'Netral 😐',
        content: 'Original content',
      );
      
      await repository.add(originalEntry);
      
      final updatedEntry = JournalEntry(
        id: originalEntry.id,
        date: originalEntry.date,
        mood: 'Senang 😊',
        content: 'Updated content - much better!',
      );
      
      await repository.update(updatedEntry);
      
      final journals = await repository.getAll();
      expect(journals.length, 1);
      expect(journals.first.content, 'Updated content - much better!');
      expect(journals.first.mood, 'Senang 😊');
      
      print('Test passed: Entry successfully updated');
    });

    test('should delete entries', () async {
      final repository = JournalRepository();
      
      final entry = JournalEntry(
        date: DateTime.now(),
        mood: 'Cemas 😰',
        content: 'This entry will be deleted',
      );
      
      await repository.add(entry);
      var journals = await repository.getAll();
      expect(journals.length, 1);
      
      await repository.delete(entry.id);
      journals = await repository.getAll();
      expect(journals.length, 0);
      
      print('Test passed: Entry successfully deleted');
    });
  });
}
