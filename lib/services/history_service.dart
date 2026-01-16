import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryService {
  static const String _key = 'history_results';

  static Future<void> saveResult(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList(_key) ?? [];
    
    historyJson.insert(0, json.encode(item.toMap())); // Dodaj na vrh liste
    await prefs.setStringList(_key, historyJson);
  }

static Future<List<HistoryItem>> getHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> historyJson = prefs.getStringList(_key) ?? [];

  final items = <HistoryItem>[];
  for (final s in historyJson) {
    try {
      final map = json.decode(s) as Map<String, dynamic>;
      items.add(HistoryItem.fromMap(map));
    } catch (e) {
      // preskoči pokvarene unose da ne sruše celu istoriju
      // (možeš i da debugPrint ovde)
    }
  }
  return items;
}


  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}