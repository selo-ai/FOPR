import 'package:hive_flutter/hive_flutter.dart';
import '../models/overtime.dart';
import '../models/settings.dart';
import '../models/leave.dart';
import '../models/leave_type.dart';

class DatabaseService {
  static const String overtimeBoxName = 'overtimes';
  static const String settingsBoxName = 'settings';
  static const String leaveBoxName = 'leaves';

  static late Box<Overtime> _overtimeBox;
  static late Box<Settings> _settingsBox;
  static late Box<Leave> _leaveBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(OvertimeAdapter());
    Hive.registerAdapter(SettingsAdapter());
    Hive.registerAdapter(LeaveAdapter());
    Hive.registerAdapter(LeaveTypeAdapter());

    // Open boxes
    _overtimeBox = await Hive.openBox<Overtime>(overtimeBoxName);
    _settingsBox = await Hive.openBox<Settings>(settingsBoxName);
    _leaveBox = await Hive.openBox<Leave>(leaveBoxName);

    // Initialize settings if not exists
    if (_settingsBox.isEmpty) {
      await _settingsBox.put('default', Settings());
    }
  }

  // ============ Overtime Operations ============

  static Box<Overtime> get overtimeBox => _overtimeBox;

  static List<Overtime> getAllOvertimes() {
    return _overtimeBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> addOvertime(Overtime overtime) async {
    await _overtimeBox.put(overtime.id, overtime);
  }

  static Future<void> updateOvertime(Overtime overtime) async {
    await overtime.save();
  }

  static Future<void> deleteOvertime(String id) async {
    await _overtimeBox.delete(id);
  }

  static List<Overtime> getOvertimesByMonth(int year, int month) {
    return getAllOvertimes().where((o) {
      return o.date.year == year && o.date.month == month;
    }).toList();
  }

  static List<Overtime> getOvertimesByYear(int year) {
    return getAllOvertimes().where((o) => o.date.year == year).toList();
  }

  static double getMonthlyTotal(int year, int month) {
    return getOvertimesByMonth(year, month).fold(0.0, (sum, o) => sum + o.hours);
  }

  static double getYearlyTotal(int year) {
    return getOvertimesByYear(year).fold(0.0, (sum, o) => sum + o.hours);
  }

  // ============ Leave Operations ============

  static Box<Leave> get leaveBox => _leaveBox;

  static List<Leave> getAllLeaves() {
    return _leaveBox.values.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  static Future<void> addLeave(Leave leave) async {
    await _leaveBox.put(leave.id, leave);
  }

  static Future<void> updateLeave(Leave leave) async {
    await leave.save();
  }

  static Future<void> deleteLeave(String id) async {
    await _leaveBox.delete(id);
  }

  static List<Leave> getLeavesByYear(int year) {
    return getAllLeaves().where((l) => l.startDate.year == year).toList();
  }

  static List<Leave> getLeavesByType(LeaveType type, {int? year}) {
    var leaves = getAllLeaves().where((l) => l.type == type);
    if (year != null) {
      leaves = leaves.where((l) => l.startDate.year == year);
    }
    return leaves.toList();
  }

  /// Kıdem yılına göre yıllık izin hak edişini hesaplar
  static int calculateAnnualEntitlement() {
    final settings = getSettings();
    if (settings.startDate == null) return 18; // Default

    final now = DateTime.now();
    final yearsWorked = now.difference(settings.startDate!).inDays ~/ 365;

    if (yearsWorked >= 15) return 26;
    if (yearsWorked >= 6) return 22;
    return 18;
  }

  /// Yılda kullanılan yıllık izin günlerini hesaplar (sadece kotadan düşenler)
  static double getUsedAnnualLeaveDays(int year) {
    return getLeavesByYear(year)
        .where((l) => l.type.deductsFromQuota)
        .fold(0.0, (sum, l) => sum + l.days);
  }

  /// Kalan yıllık izin günlerini hesaplar
  static double getRemainingAnnualLeaveDays(int year) {
    final entitlement = calculateAnnualEntitlement();
    final used = getUsedAnnualLeaveDays(year);
    return entitlement - used;
  }

  /// İzin türüne göre kullanılan toplam günleri hesaplar
  static double getTotalDaysByType(LeaveType type, int year) {
    return getLeavesByType(type, year: year).fold(0.0, (sum, l) => sum + l.days);
  }

  // ============ Settings Operations ============

  static Settings getSettings() {
    return _settingsBox.get('default') ?? Settings();
  }

  static Future<void> saveSettings(Settings settings) async {
    await _settingsBox.put('default', settings);
  }
}
