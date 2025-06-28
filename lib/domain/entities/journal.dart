// lib/domain/entities/journal.dart

import 'package:freezed_annotation/freezed_annotation.dart';

// Baris-baris ini diperlukan untuk code generator.
// Nama file harus cocok.
part 'journal.freezed.dart';
part 'journal.g.dart';

@freezed
class Journal with _$Journal {
  // Konstruktor factory ini mendefinisikan struktur data kita.
  // Ini mirip dengan properti di data class Kotlin Anda.
  const factory Journal({
    required String id,
    required String title,
    required String content,
    required String mood,
    
    // Di Kotlin: createdAt: OffsetDateTime
    // Di Dart, kita gunakan DateTime. json_serializable akan meng-handle konversinya.
    // Anotasi @JsonKey digunakan untuk mencocokkan nama field dari JSON API.
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Journal;

  // Factory ini penting agar kita bisa membuat objek Journal dari JSON.
  factory Journal.fromJson(Map<String, dynamic> json) => _$JournalFromJson(json);
}