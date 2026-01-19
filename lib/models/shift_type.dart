import 'package:hive/hive.dart';

part 'shift_type.g.dart';

@HiveType(typeId: 4)
enum ShiftType {
  @HiveField(0)
  night,
  
  @HiveField(1)
  morning,
  
  @HiveField(2)
  evening,
}

extension ShiftTypeExtension on ShiftType {
  String get displayName {
    switch (this) {
      case ShiftType.night:
        return 'Gece';
      case ShiftType.morning:
        return 'Sabah';
      case ShiftType.evening:
        return 'Akşam';
    }
  }

  String get icon {
    switch (this) {
      case ShiftType.night:
        return '🌙';
      case ShiftType.morning:
        return '☀️';
      case ShiftType.evening:
        return '🌅';
    }
  }

  String get assetPath {
    switch (this) {
      case ShiftType.night:
        return 'assets/images/shift_night.png';
      case ShiftType.morning:
        return 'assets/images/shift_morning.png';
      case ShiftType.evening:
        return 'assets/images/shift_evening.png';
    }
  }

  String get timeRange {
    switch (this) {
      case ShiftType.night:
        return '00:00 - 08:00';
      case ShiftType.morning:
        return '08:00 - 16:00';
      case ShiftType.evening:
        return '16:00 - 00:00';
    }
  }

  /// Döngüdeki sıra indeksi (Gece=0, Akşam=1, Sabah=2)
  int get cycleIndex {
    switch (this) {
      case ShiftType.night:
        return 0;
      case ShiftType.morning:
        return 2;
      case ShiftType.evening:
        return 1;
    }
  }

  /// Döngüdeki bir sonraki vardiya
  ShiftType get nextInCycle {
    // Gece → Akşam → Sabah → Gece
    switch (this) {
      case ShiftType.night:
        return ShiftType.evening;
      case ShiftType.evening:
        return ShiftType.morning;
      case ShiftType.morning:
        return ShiftType.night;
    }
  }

  /// İndeksten vardiya tipi
  static ShiftType fromCycleIndex(int index) {
    final normalized = index % 3;
    switch (normalized) {
      case 0:
        return ShiftType.night;
      case 1:
        return ShiftType.evening;
      case 2:
        return ShiftType.morning;
      default:
        return ShiftType.night;
    }
  }
}
