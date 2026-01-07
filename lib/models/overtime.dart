import 'package:hive/hive.dart';

part 'overtime.g.dart';

@HiveType(typeId: 0)
class Overtime extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late double hours;

  @HiveField(3)
  String? note;

  @HiveField(4)
  late DateTime createdAt;

  Overtime({
    required this.id,
    required this.date,
    required this.hours,
    this.note,
    required this.createdAt,
  });

  // Katsayı x2 olarak hesaplanacak
  double get calculatedHours => hours * 2;
}
