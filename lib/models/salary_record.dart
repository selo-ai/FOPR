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

  @HiveField(13, defaultValue: 0.0)
  double totalSundayHours;

  @HiveField(14, defaultValue: 0.0)
  double publicHolidayHours;

  @HiveField(15, defaultValue: 0.0)
  double annualLeaveDays;

  @HiveField(16, defaultValue: 0.0)
  double otosanAllowance;

  @HiveField(17, defaultValue: 0.0)
  double holidayAllowance; // Hive v17 (Bayram Harçlığı)

  @HiveField(18, defaultValue: 0.0)
  double leaveAllowance; // Hive v18 (İzin Harçlığı)

  @HiveField(19, defaultValue: 0.0)
  double tahsilAllowance; // Hive v19 (Tahsil Yardımı)

  @HiveField(20, defaultValue: 0.0)
  double shoeAllowance;

  @HiveField(21, defaultValue: 0.0)
  double jobIndemnity; // Hive v21 (Görev Tazminatı)

  @HiveField(22, defaultValue: 0.0)
  double tisAdvance; // Hive v22 (TİS Ön Ödeme)

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
    this.totalSundayHours = 0.0,
    this.publicHolidayHours = 0.0,
    this.annualLeaveDays = 0.0,
    this.otosanAllowance = 0.0,
    this.holidayAllowance = 0.0,
    this.leaveAllowance = 0.0,
    this.tahsilAllowance = 0.0,
    this.shoeAllowance = 0.0,
    this.jobIndemnity = 0.0,
    this.tisAdvance = 0.0,
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
    double publicHolidayHours = 0,
    double annualLeaveDays = 0,
    double otosanAllowance = 0,
    double holidayAllowance = 0,
    double leaveAllowance = 0,
    double tahsilAllowance = 0,
    double shoeAllowance = 0,
    double jobIndemnity = 0,
    double tisAdvance = 0,
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
      publicHolidayHours: publicHolidayHours,
      annualLeaveDays: annualLeaveDays,
      otosanAllowance: otosanAllowance,
      holidayAllowance: holidayAllowance,
      leaveAllowance: leaveAllowance,
      tahsilAllowance: tahsilAllowance,
      shoeAllowance: shoeAllowance,
      jobIndemnity: jobIndemnity,
      tisAdvance: tisAdvance,
      createdAt: DateTime.now(),
    );
  }
}
