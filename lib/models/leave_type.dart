import 'package:hive/hive.dart';

part 'leave_type.g.dart';

@HiveType(typeId: 3)
enum LeaveType {
  @HiveField(0)
  annual, // Yıllık İzin - Kotadan düşer, hafta sonları sayılmaz

  @HiveField(1)
  unpaid, // Ücretsiz İzin - Saat bazlı manuel giriş

  @HiveField(2)
  administrative, // İdari İzin - Hafta sonları sayılmaz

  @HiveField(3)
  marriage, // Evlilik İzni - 7 gün, hafta sonları dahil

  @HiveField(4)
  bereavement, // Cenaze İzni - 4 gün, hafta sonları dahil

  @HiveField(5)
  ssk, // SSK - Hastalık izni
}

extension LeaveTypeExtension on LeaveType {
  String get displayName {
    switch (this) {
      case LeaveType.annual:
        return 'Yıllık İzin';
      case LeaveType.unpaid:
        return 'Ücretsiz İzin';
      case LeaveType.administrative:
        return 'İdari İzin';
      case LeaveType.marriage:
        return 'Evlilik İzni';
      case LeaveType.bereavement:
        return 'Cenaze İzni';
      case LeaveType.ssk:
        return 'SSK';
    }
  }

  String get icon {
    switch (this) {
      case LeaveType.annual:
        return '🏖️';
      case LeaveType.unpaid:
        return '💰';
      case LeaveType.administrative:
        return '📋';
      case LeaveType.marriage:
        return '💒';
      case LeaveType.bereavement:
        return '🕯️';
      case LeaveType.ssk:
        return '🏥';
    }
  }

  /// Bu izin türü yıllık izin kotasından düşer mi?
  bool get deductsFromQuota => this == LeaveType.annual;

  /// Bu izin türünde hafta sonları izinden sayılır mı?
  bool get includesWeekends {
    switch (this) {
      case LeaveType.marriage:
      case LeaveType.bereavement:
      case LeaveType.ssk:
      case LeaveType.unpaid:
        return true;
      case LeaveType.annual:
      case LeaveType.administrative:
        return false;
    }
  }

  /// Sabit süreli izin mi? (null = değişken)
  int? get fixedDays {
    switch (this) {
      case LeaveType.marriage:
        return 7;
      case LeaveType.bereavement:
        return 4;
      default:
        return null;
    }
  }

  /// Saat bazlı giriş mi? (Ücretsiz izin için)
  bool get isHourBased => this == LeaveType.unpaid;
}
