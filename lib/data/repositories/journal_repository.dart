import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dear_flutter/domain/entities/journal_entry.dart';

class JournalRepository {
  static const _key = 'journal_entries';

  Future<List<JournalEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    final List list = json.decode(jsonStr);
    return list.map((e) => JournalEntry.fromJson(e)).toList();
  }

  Future<void> add(JournalEntry entry) async {
    final list = await getAll();
    list.add(entry);
    await _saveAll(list);
  }

  Future<void> update(JournalEntry entry) async {
    final list = await getAll();
    final idx = list.indexWhere((e) => e.id == entry.id);
    if (idx != -1) {
      list[idx] = entry;
      await _saveAll(list);
    }
  }

  Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((e) => e.id == id);
    await _saveAll(list);
  }

  Future<void> _saveAll(List<JournalEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
