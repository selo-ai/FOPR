import '../models/shift_type.dart';
import '../utils/holiday_utils.dart';
import 'database_service.dart';

/// Merkezi takvim servisi - tüm modüller bu servisi kullanır
class ShiftCalendarService {
  /// Belirli bir tarih için vardiya tipini hesaplar
  /// Haftalık döngü: Gece → Akşam → Sabah
  static ShiftType getShiftForDate(DateTime date) {
    final settings = DatabaseService.getSettings();
    
    // Başlangıç tarihi yoksa bugünü başlangıç kabul et
    final startDate = settings.shiftStartDate ?? DateTime.now();
    final startShiftIndex = settings.currentShiftTypeIndex;

    // Tarihleri sadece gün bazında (saatleri sıfırlayarak) al
    final d1 = DateTime(startDate.year, startDate.month, startDate.day);
    final d2 = DateTime(date.year, date.month, date.day);

    // Her iki tarihi de o haftanın Pazartesi gününe yuvarla
    // weekday: Pazartesi=1 ... Pazar=7
    final d1Monday = d1.subtract(Duration(days: d1.weekday - 1));
    final d2Monday = d2.subtract(Duration(days: d2.weekday - 1));

    // Pazartesiler arası gün farkı
    final daysDiff = d2Monday.difference(d1Monday).inDays;
    
    // Kaç hafta geçmiş?
    final weeksDiff = (daysDiff / 7).floor();
    
    // Negatif hafta farkı için düzeltme (geçmiş tarihler)
    // weeksDiff % 3 sonucu negatif olabilir, o yüzden +3 ekleyip tekrar mod alıyoruz
    final effectiveWeeks = ((weeksDiff % 3) + 3) % 3;
    
    // Yeni vardiya indeksi (döngü: 0→1→2→0...)
    final newShiftIndex = (startShiftIndex + effectiveWeeks) % 3;
    
    return ShiftTypeExtension.fromCycleIndex(newShiftIndex);
  }

  /// Belirli ay için gece vardiyası gün sayısını hesaplar
  static int countNightShiftsInMonth(int year, int month) {
    int count = 0;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    
    for (var day = firstDay; day.isBefore(lastDay) || day.isAtSameMomentAs(lastDay); day = day.add(const Duration(days: 1))) {
      // Pazar günleri hariç (tatil)
      if (day.weekday == DateTime.sunday) continue;
      
      if (getShiftForDate(day) == ShiftType.night) {
        count++;
      }
    }
    
    return count;
  }

  /// Belirli ay için akşam vardiyası gün sayısını hesaplar
  static int countEveningShiftsInMonth(int year, int month) {
    int count = 0;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    
    for (var day = firstDay; day.isBefore(lastDay) || day.isAtSameMomentAs(lastDay); day = day.add(const Duration(days: 1))) {
      if (day.weekday == DateTime.sunday) continue;
      
      if (getShiftForDate(day) == ShiftType.evening) {
        count++;
      }
    }
    
    return count;
  }

  /// Aylık takvim verisi döndürür
  static List<ShiftDay> getMonthCalendar(int year, int month) {
    final result = <ShiftDay>[];
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    
    for (var day = firstDay; day.isBefore(lastDay) || day.isAtSameMomentAs(lastDay); day = day.add(const Duration(days: 1))) {
      final isSunday = day.weekday == DateTime.sunday;
      final shift = isSunday ? null : getShiftForDate(day);
      final holidayAmount = HolidayUtils.getHolidayAmount(day);
      
      result.add(ShiftDay(
        date: day,
        shiftType: shift,
        isSunday: isSunday,
        isToday: _isSameDay(day, DateTime.now()),
        isPublicHoliday: holidayAmount > 0,
        holidayAmount: holidayAmount,
      ));
    }
    
    return result;
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Tek bir gün için takvim verisi
class ShiftDay {
  final DateTime date;
  final ShiftType? shiftType; // null = tatil
  final bool isSunday;
  final bool isToday;
  final bool isPublicHoliday;
  final double holidayAmount;

  ShiftDay({
    required this.date,
    this.shiftType,
    required this.isSunday,
    required this.isToday,
    this.isPublicHoliday = false,
    this.holidayAmount = 0.0,
  });
}
