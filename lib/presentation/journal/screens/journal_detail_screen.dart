import 'package:dear_flutter/domain/entities/journal_entry.dart';
import 'package:flutter/material.dart';

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;
  const JournalDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF8FAFC);
    const cardColor = Color(0xFFEFF3F6);
    const accentColor = Color(0xFFB4C5E4);
    const textColor = Color(0xFF22223B);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Detail Jurnal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(entry.mood, style: const TextStyle(fontSize: 54)),
            const SizedBox(height: 10),
            Text(
              _formatDate(entry.date),
              style: TextStyle(
                fontSize: 15,
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                entry.content,
                style: TextStyle(fontSize: 17, color: textColor.withOpacity(0.95)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hari ini';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Kemarin';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}
