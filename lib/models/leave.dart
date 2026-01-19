import 'package:hive/hive.dart';
import '../utils/holiday_utils.dart';
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
  static double calculateDays(
    DateTime start, 
    DateTime end, 
    bool includesWeekends, {
    bool excludeHolidays = false,
  }) {
    // Toplam gün farkı + 1 (başlangıç ve bitiş dahil)
    double count = 0;
    DateTime current = start;
    
    // Günü sıfırlayarak sadece tarih karşılaştırması yapalım (saat farkını yok saymak için)
    final endDate = DateTime(end.year, end.month, end.day);
    
    while (!DateTime(current.year, current.month, current.day).isAfter(endDate)) {
      bool isWorkDay = true;
      
      // 1. Hafta sonu kontrolü
      if (!includesWeekends) {
        if (current.weekday == DateTime.sunday) {
          isWorkDay = false;
        }
      }
      
      // 2. Resmi tatil kontrolü (Eğer hafta sonu değilse veya hafta sonu dahillerde de tatil düşülecekse)
      // Ancak genellikle yıllık izin (resmi tatiller hariç) hafta sonu da sayılmaz.
      // Sadece "iş günü" ise tatil kontrolü yapılır.
      if (isWorkDay && excludeHolidays) {
        final holidayAmount = HolidayUtils.getHolidayAmount(current);
        if (holidayAmount > 0) {
          // Eğer tam gün tatilse isWorkDay = false
          // Eğer yarım gün se (0.5), o zaman 0.5 gün ekle?
          // Mantık: count += (1 - holidayAmount)
          count += (1.0 - holidayAmount);
          isWorkDay = false; // count'u yukarıda elle yönettik
        }
      }
      
      if (isWorkDay) {
        count++;
      }
      
      current = current.add(const Duration(days: 1));
    }
    
    return count;
  }

  /// Belirtilen aralıktaki resmi tatil gün sayısını hesaplar
  static double calculateHolidayCount(DateTime start, DateTime end) {
    double count = 0;
    DateTime current = start;
    final endDate = DateTime(end.year, end.month, end.day);
    
    while (!DateTime(current.year, current.month, current.day).isAfter(endDate)) {
      final holidayAmount = HolidayUtils.getHolidayAmount(current);
      count += holidayAmount;
      current = current.add(const Duration(days: 1));
    }
    
    return count;
  }

  /// Yıllık izin kotasından düşülecek gün sayısı
  double get quotaDeduction {
    if (type.deductsFromQuota) {
      return days;
    }
    return 0;
  }
}
