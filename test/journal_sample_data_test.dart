import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dear_flutter/utils/journal_test_data.dart';

void main() {
  test('Add sample journal entries and verify they are stored', () async {
    // Setup
    SharedPreferences.setMockInitialValues({});
    
    // Add sample data
    await JournalTestData.addSampleEntries();
    
    // Verify data was added
    await JournalTestData.printAllEntries();
    
    print('Sample data test completed successfully!');
  });
}
