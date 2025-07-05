import 'package:uuid/uuid.dart';

class JournalEntry {
  final String id;
  final DateTime date;
  final String mood;
  final String content;

  JournalEntry({
    String? id,
    required this.date,
    required this.mood,
    required this.content,
  }) : id = id ?? const Uuid().v4();

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String?,
        date: DateTime.parse(json['date'] as String),
        mood: json['mood'] as String,
        content: json['content'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mood': mood,
        'content': content,
      };
}
