import 'package:hive_flutter/hive_flutter.dart';
import '../models/overtime.dart';
import '../models/settings.dart';
import '../models/leave.dart';
import '../models/leave_type.dart';
import '../models/shift_type.dart';
import '../utils/holiday_utils.dart';

import '../models/note.dart';
import '../models/salary_settings.dart';
import '../models/salary_record.dart';

class DatabaseService {
  static const String overtimeBoxName = 'overtimes';
  static const String settingsBoxName = 'settings';
  static const String leaveBoxName = 'leaves';
  static const String noteBoxName = 'notes';
  static const String salarySettingsBoxName = 'salary_settings';
  static const String salaryRecordBoxName = 'salary_records';

  static late Box<Overtime> _overtimeBox;
  static late Box<Settings> _settingsBox;
  static late Box<Leave> _leaveBox;
  static late Box<Note> _noteBox;
  static late Box<SalarySettings> _salarySettingsBox;
  static late Box<SalaryRecord> _salaryRecordBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(OvertimeAdapter());
    Hive.registerAdapter(SettingsAdapter());
    Hive.registerAdapter(LeaveAdapter());
    Hive.registerAdapter(LeaveTypeAdapter());
    Hive.registerAdapter(ShiftTypeAdapter());
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(SalarySettingsAdapter());
    Hive.registerAdapter(SalaryRecordAdapter());

    // Open boxes
    _overtimeBox = await Hive.openBox<Overtime>(overtimeBoxName);
    _settingsBox = await Hive.openBox<Settings>(settingsBoxName);
    _leaveBox = await Hive.openBox<Leave>(leaveBoxName);
    _noteBox = await Hive.openBox<Note>(noteBoxName);
    _salarySettingsBox = await Hive.openBox<SalarySettings>(salarySettingsBoxName);
    _salaryRecordBox = await Hive.openBox<SalaryRecord>(salaryRecordBoxName);

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

  static double getSundayOvertimeTotal(int year, int month) {
    return getOvertimesByMonth(year, month)
        .where((o) => o.date.weekday == DateTime.sunday)
        .fold(0.0, (sum, o) => sum + o.hours);
  }

  static double getPublicHolidayOvertimeTotal(int year, int month) {
    return getOvertimesByMonth(year, month)
        .where((o) {
            // Pazar hariç ve Resmi Tatil olanlar
            if (o.date.weekday == DateTime.sunday) return false;
            return HolidayUtils.getHolidayAmount(o.date) > 0;
        })
        .fold(0.0, (sum, o) => sum + o.hours);
  }

  // ============ Leave Operations ============

  static Box<Leave> get leaveBox => _leaveBox;

  static List<Leave> getLeavesByMonth(int year, int month) {
    if (!_leaveBox.isOpen) return [];
    
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    return _leaveBox.values.where((l) {
      final start = DateTime(l.startDate.year, l.startDate.month, l.startDate.day);
      final end = DateTime(l.endDate.year, l.endDate.month, l.endDate.day);
      
      return start.compareTo(lastDay) <= 0 && end.compareTo(firstDay) >= 0;
    }).toList();
  }

  static double getAnnualLeaveDaysInMonth(int year, int month) {
    final leaves = getLeavesByMonth(year, month);
    double totalDays = 0;
    
    final monthFirst = DateTime(year, month, 1);
    final monthLast = DateTime(year, month + 1, 0);

    for (var leave in leaves) {
      if (leave.type != LeaveType.annual) continue;

      DateTime start = leave.startDate.isBefore(monthFirst) ? monthFirst : leave.startDate;
      DateTime end = leave.endDate.isAfter(monthLast) ? monthLast : leave.endDate;
      
      totalDays += Leave.calculateDays(start, end, false, excludeHolidays: true);
    }
    return totalDays;
  }

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

  /// Belirli bir ayda kullanılan izin günlerini hesaplar
  static double getUsedLeaveDaysByMonth(int year, int month) {
    return getAllLeaves()
        .where((l) => l.startDate.year == year && l.startDate.month == month)
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

  // ============ Note Operations ============

  static Box<Note> get noteBox => _noteBox;

  static List<Note> getAllNotes() {
    return _noteBox.values.toList()
      ..sort((a, b) {
        // First sort by starred (starred first)
        if (a.isStarred != b.isStarred) {
          return a.isStarred ? -1 : 1;
        }
        // Then sort by updatedAt (newest first)
        return b.updatedAt.compareTo(a.updatedAt);
      });
  }

  static Future<void> addNote(Note note) async {
    await _noteBox.put(note.id, note);
  }

  static Future<void> updateNote(Note note) async {
    note.updatedAt = DateTime.now();
    await note.save();
  }

  static Future<void> deleteNote(String id) async {
    await _noteBox.delete(id);
  }

  // ============ Salary Operations ============

  static Future<SalarySettings> getSalarySettings() async {
    if (_salarySettingsBox.isEmpty) {
      // Default settings
      final defaultSettings = SalarySettings(
        hourlyGrossRate: 0.0,
      );
      await _salarySettingsBox.put('default', defaultSettings);
      return defaultSettings;
    }
    return _salarySettingsBox.get('default')!;
  }

  static Future<void> saveSalarySettings(SalarySettings settings) async {
    await _salarySettingsBox.put('default', settings);
  }

  static List<SalaryRecord> getAllSalaryRecords() {
    return _salaryRecordBox.values.toList()
      ..sort((a, b) {
        if (a.year != b.year) {
          return b.year.compareTo(a.year);
        }
        return b.month.compareTo(a.month);
      });
  }

  static SalaryRecord? getSalaryRecord(int year, int month) {
    try {
      return _salaryRecordBox.values.firstWhere(
        (salary) => salary.year == year && salary.month == month,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveSalaryRecord(SalaryRecord record) async {
    await _salaryRecordBox.put(record.id, record);
  }

  static Future<void> deleteSalaryRecord(String id) async {
    await _salaryRecordBox.delete(id);
  }
}
