import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'settings.g.dart';

@HiveType(typeId: 1)
class Settings extends HiveObject {
  // Kişisel Bilgiler
  @HiveField(0)
  String? fullName;

  @HiveField(1)
  String? employeeId;

  @HiveField(2)
  DateTime? startDate;

  // Mesai Ayarları
  @HiveField(3)
  double hourlyRate;

  @HiveField(4)
  double monthlyQuota;

  @HiveField(5)
  double yearlyQuota;

  // Tema
  @HiveField(6)
  int themeModeIndex; // 0: system, 1: light, 2: dark

  // Tutorial flags
  @HiveField(7, defaultValue: false)
  bool overtimeTutorialShown;

  @HiveField(9, defaultValue: false)
  bool salarySettingsReminderShown;

  // Vardiya Ayarları
  @HiveField(10, defaultValue: 0)
  int currentShiftTypeIndex; // 0: night, 1: morning, 2: evening

  @HiveField(11)
  DateTime? shiftStartDate; // Vardiya döngüsünün başlangıç tarihi

  Settings({
    this.fullName,
    this.employeeId,
    this.startDate,
    this.hourlyRate = 0.0,
    this.monthlyQuota = 0.0,
    this.yearlyQuota = 0.0,
    this.themeModeIndex = 0,
    this.overtimeTutorialShown = false,
    this.salarySettingsReminderShown = false,
    this.currentShiftTypeIndex = 0,
    this.shiftStartDate,
  });

  ThemeMode get themeMode {
    switch (themeModeIndex) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        themeModeIndex = 1;
        break;
      case ThemeMode.dark:
        themeModeIndex = 2;
        break;
      default:
        themeModeIndex = 0;
    }
  }
}
