import 'package:hive_flutter/hive_flutter.dart';
import '../models/overtime.dart';
import '../models/settings.dart';

class DatabaseService {
  static const String overtimeBoxName = 'overtimes';
  static const String settingsBoxName = 'settings';

  static late Box<Overtime> _overtimeBox;
  static late Box<Settings> _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(OvertimeAdapter());
    Hive.registerAdapter(SettingsAdapter());

    // Open boxes
    _overtimeBox = await Hive.openBox<Overtime>(overtimeBoxName);
    _settingsBox = await Hive.openBox<Settings>(settingsBoxName);

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

  // ============ Settings Operations ============

  static Settings getSettings() {
    return _settingsBox.get('default') ?? Settings();
  }

  static Future<void> saveSettings(Settings settings) async {
    await _settingsBox.put('default', settings);
  }
}
