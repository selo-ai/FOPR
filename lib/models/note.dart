import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'note.g.dart';

@HiveType(typeId: 5)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  bool isStarred;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.isStarred = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.create({
    required String title,
    required String content,
    bool isStarred = false,
  }) {
    final now = DateTime.now();
    return Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      isStarred: isStarred,
      createdAt: now,
      updatedAt: now,
    );
  }
}
