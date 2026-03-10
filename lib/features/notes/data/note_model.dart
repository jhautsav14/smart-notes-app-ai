import 'package:hive/hive.dart';

part 'note_model.g.dart'; // Run build_runner to generate this file

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  String? aiSummary;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.aiSummary,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    String? aiSummary,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      aiSummary: aiSummary ?? this.aiSummary,
    );
  }
}
