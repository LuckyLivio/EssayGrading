import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'grading_result.dart';

class HistoryRecord {
  final String id;
  final String title;
  final String questionType;
  final String answerText;
  final GradingResult result;
  final DateTime createdAt;

  HistoryRecord({
    String? id,
    required this.title,
    required this.questionType,
    required this.answerText,
    required this.result,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      id: json['id'],
      title: json['title'],
      questionType: json['questionType'],
      answerText: json['answerText'],
      result: GradingResult.fromJson(json['result']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'questionType': questionType,
      'answerText': answerText,
      'result': result.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper to convert to/from string for Hive storage
  String toJsonString() => jsonEncode(toJson());
  
  factory HistoryRecord.fromJsonString(String str) => 
      HistoryRecord.fromJson(jsonDecode(str));
}
