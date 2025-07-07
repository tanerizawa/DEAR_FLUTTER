import 'package:flutter/material.dart';
import 'package:dear_flutter/data/repositories/journal_repository.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';
import 'package:dear_flutter/utils/journal_test_data.dart';

/// Simple debug screen to test journal functionality directly
class JournalDebugScreen extends StatefulWidget {
  const JournalDebugScreen({super.key});

  @override
  State<JournalDebugScreen> createState() => _JournalDebugScreenState();
}

class _JournalDebugScreenState extends State<JournalDebugScreen> {
  List<JournalEntry> _journals = [];
  bool _loading = false;
  String _status = 'Ready';

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    setState(() {
      _loading = true;
      _status = 'Loading journals...';
    });

    try {
      final repository = JournalRepository();
      final journals = await repository.getAll();
      
      setState(() {
        _journals = journals;
        _loading = false;
        _status = 'Loaded ${journals.length} journals';
      });
      
      print('[JOURNAL DEBUG] Loaded ${journals.length} journals');
      for (int i = 0; i < journals.length; i++) {
        print('[JOURNAL DEBUG] $i: ${journals[i].mood} - ${journals[i].content.substring(0, journals[i].content.length > 30 ? 30 : journals[i].content.length)}...');
      }
    } catch (e, stackTrace) {
      setState(() {
        _loading = false;
        _status = 'Error: $e';
      });
      print('[JOURNAL DEBUG] Error loading journals: $e');
      print('[JOURNAL DEBUG] Stack trace: $stackTrace');
    }
  }

  Future<void> _addSampleData() async {
    setState(() {
      _status = 'Adding sample data...';
    });

    try {
      await JournalTestData.addSampleEntries();
      setState(() {
        _status = 'Sample data added';
      });
      _loadJournals();
    } catch (e) {
      setState(() {
        _status = 'Error adding sample data: $e';
      });
    }
  }

  Future<void> _clearAllData() async {
    setState(() {
      _status = 'Clearing all data...';
    });

    try {
      final repository = JournalRepository();
      await repository.clearAll();
      setState(() {
        _status = 'All data cleared';
      });
      _loadJournals();
    } catch (e) {
      setState(() {
        _status = 'Error clearing data: $e';
      });
    }
  }

  Future<void> _addTestEntry() async {
    setState(() {
      _status = 'Adding test entry...';
    });

    try {
      final repository = JournalRepository();
      final entry = JournalEntry(
        date: DateTime.now(),
        mood: 'Senang 😊',
        content: 'Test entry created from debug screen at ${DateTime.now().toString()}',
      );
      
      await repository.add(entry);
      setState(() {
        _status = 'Test entry added';
      });
      _loadJournals();
    } catch (e) {
      setState(() {
        _status = 'Error adding test entry: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Debug'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: $_status',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Total Journals: ${_journals.length}'),
                  Text('Loading: $_loading'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            ElevatedButton.icon(
              onPressed: _loading ? null : _loadJournals,
              icon: const Icon(Icons.refresh),
              label: const Text('Reload Journals'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: _loading ? null : _addSampleData,
              icon: const Icon(Icons.data_object),
              label: const Text('Add Sample Data'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: _loading ? null : _addTestEntry,
              icon: const Icon(Icons.add),
              label: const Text('Add Test Entry'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: _loading ? null : _clearAllData,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Clear All Data'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            
            const SizedBox(height: 20),
            
            // Journal list
            Expanded(
              child: _loading 
                ? const Center(child: CircularProgressIndicator())
                : _journals.isEmpty
                  ? Center(
                      child: Text(
                        'No journals found',
                        style: TextStyle(
                          fontSize: 16, 
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _journals.length,
                      itemBuilder: (context, index) {
                        final journal = _journals[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Text(
                              journal.mood.split(' ').last,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(
                              journal.content.length > 50 
                                ? '${journal.content.substring(0, 50)}...'
                                : journal.content,
                            ),
                            subtitle: Text(
                              '${journal.date.toLocal().toString().split(' ')[0]} - ${journal.mood.split(' ').first}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final repository = JournalRepository();
                                await repository.delete(journal.id);
                                _loadJournals();
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
