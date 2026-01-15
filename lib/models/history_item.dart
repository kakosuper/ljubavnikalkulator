import 'dart:convert';

class HistoryItem {
  final String name1;
  final String name2;
  final int score;
  final String message;
  final DateTime date;
  // Dodatni parametri za napredni mod
  final String? sun1;
  final String? asc1;
  final String? moon1;
  final String? sun2;
  final String? asc2;
  final String? moon2;

  HistoryItem({
    required this.name1,
    required this.name2,
    required this.score,
    required this.message,
    required this.date,
    this.sun1, this.asc1, this.moon1,
    this.sun2, this.asc2, this.moon2,
  });

  // Pretvaranje u JSON za čuvanje
  Map<String, dynamic> toMap() {
    return {
      'name1': name1,
      'name2': name2,
      'score': score,
      'message': message,
      'date': date.toIso8601String(),
      'sun1': sun1, 'asc1': asc1, 'moon1': moon1,
      'sun2': sun2, 'asc2': asc2, 'moon2': moon2,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      name1: map['name1'],
      name2: map['name2'],
      score: map['score'],
      message: map['message'],
      date: DateTime.parse(map['date']),
      sun1: map['sun1'], asc1: map['asc1'], moon1: map['moon1'],
      sun2: map['sun2'], asc2: map['asc2'], moon2: map['moon2'],
    );
  }
}