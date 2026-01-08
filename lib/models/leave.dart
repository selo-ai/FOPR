import 'package:hive/hive.dart';
import 'leave_type.dart';

part 'leave.g.dart';

@HiveType(typeId: 2)
class Leave extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  LeaveType type;

  @HiveField(2)
  DateTime startDate;

  @HiveField(3)
  DateTime endDate;

  @HiveField(4)
  double days; // Hesaplanan iş günü sayısı

  @HiveField(5)
  double? hours; // Ücretsiz izin için saat (yarım gün vs.)

  @HiveField(6)
  String? note;

  @HiveField(7)
  DateTime createdAt;

  Leave({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.days,
    this.hours,
    this.note,
    required this.createdAt,
  });

  /// İş günü sayısını hesaplar (pazar günü hariç veya dahil)
  static double calculateDays(DateTime start, DateTime end, bool includesWeekends) {
    if (includesWeekends) {
      // Tüm günleri say
      return end.difference(start).inDays + 1;
    } else {
      // Sadece iş günlerini say (Pazar hariç - 6 günlük çalışma sistemi)
      double count = 0;
      DateTime current = start;
      while (!current.isAfter(end)) {
        if (current.weekday != DateTime.sunday) {
          count++;
        }
        current = current.add(const Duration(days: 1));
      }
      return count;
    }
  }

  /// Yıllık izin kotasından düşülecek gün sayısı
  double get quotaDeduction {
    if (type.deductsFromQuota) {
      return days;
    }
    return 0;
  }
}
