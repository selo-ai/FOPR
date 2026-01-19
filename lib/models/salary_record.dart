import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'salary_record.g.dart';

@HiveType(typeId: 7)
class SalaryRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int year;

  @HiveField(2)
  int month;

  @HiveField(3)
  double normalHours;

  @HiveField(4)
  double nightShiftHours;

  @HiveField(5)
  double overtimeHours;

  @HiveField(6)
  double weekendHours;

  @HiveField(7)
  double bonusAmount;

  @HiveField(8)
  double advanceAmount;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  double cachedHourlyRate;
  
  @HiveField(11)
  double totalGrossPay;

  @HiveField(12)
  double totalNetPay;

  SalaryRecord({
    required this.id,
    required this.year,
    required this.month,
    required this.normalHours,
    required this.nightShiftHours,
    required this.overtimeHours,
    required this.weekendHours,
    required this.bonusAmount,
    required this.advanceAmount,
    required this.createdAt,
    this.cachedHourlyRate = 0.0,
    this.totalGrossPay = 0.0,
    this.totalNetPay = 0.0,
  });

  factory SalaryRecord.create({
    required int year,
    required int month,
    double normalHours = 0,
    double nightShiftHours = 0,
    double overtimeHours = 0,
    double weekendHours = 0,
    double bonusAmount = 0,
    double advanceAmount = 0,
  }) {
    return SalaryRecord(
      id: const Uuid().v4(),
      year: year,
      month: month,
      normalHours: normalHours,
      nightShiftHours: nightShiftHours,
      overtimeHours: overtimeHours,
      weekendHours: weekendHours,
      bonusAmount: bonusAmount,
      advanceAmount: advanceAmount,
      createdAt: DateTime.now(),
    );
  }
}
