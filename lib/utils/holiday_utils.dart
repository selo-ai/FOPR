class HolidayUtils {
  static double getHolidayAmount(DateTime date) {
    if (date.year == 2026) {
      return _get2026Holiday(date);
    } else if (date.year == 2027) {
      return _get2027Holiday(date);
    }
    return 0.0;
  }

  static double _get2026Holiday(DateTime date) {
    final month = date.month;
    final day = date.day;

    // Yılbaşı
    if (month == 1 && day == 1) return 1.0;

    // Ramazan Bayramı (19 Mart Arife, 20-22 Bayram)
    if (month == 3) {
      if (day == 19) return 0.5; // Arife
      if (day >= 20 && day <= 22) return 1.0;
    }

    // 23 Nisan
    if (month == 4 && day == 23) return 1.0;

    // 1 Mayıs
    if (month == 5 && day == 1) return 1.0;

    // 19 Mayıs
    if (month == 5 && day == 19) return 1.0;

    // Kurban Bayramı (26 Mayıs Arife, 27-30 Bayram)
    if (month == 5) {
      if (day == 26) return 0.5; // Arife
      if (day >= 27 && day <= 30) return 1.0;
    }

    // 15 Temmuz
    if (month == 7 && day == 15) return 1.0;

    // 30 Ağustos
    if (month == 8 && day == 30) return 1.0;

    // 29 Ekim (28 Ekim Arife)
    if (month == 10) {
      if (day == 28) return 0.5; // Yarım gün
      if (day == 29) return 1.0;
    }

    return 0.0;
  }

  static double _get2027Holiday(DateTime date) {
    final month = date.month;
    final day = date.day;

    // Yılbaşı
    if (month == 1 && day == 1) return 1.0;

    // Ramazan Bayramı (8 Mart Arife, 9-11 Bayram)
    if (month == 3) {
      if (day == 8) return 0.5; // Arife
      if (day >= 9 && day <= 11) return 1.0;
    }

    // 23 Nisan
    if (month == 4 && day == 23) return 1.0;

    // 1 Mayıs
    if (month == 5 && day == 1) return 1.0;

    // 19 Mayıs (Not: Kurban bayramı ile çakışıyor mu? 2027'de Kurban 16-19 Mayıs)
    // 15 Mayıs Arife, 16-19 Kurban.
    // 19 Mayıs hem bayram hem 19 Mayıs. 1 gün sayılır.
    
    // Kurban Bayramı (15 Mayıs Arife, 16-19 Bayram)
    if (month == 5) {
      if (day == 15) return 0.5; // Arife
      if (day >= 16 && day <= 19) return 1.0;
    }
    
    // 19 Mayıs kontrolü (Kurban'ın içinde olsa da ayrı kontrol edelim, zaten 1.0 dönecek)
    if (month == 5 && day == 19) return 1.0;

    // 15 Temmuz
    if (month == 7 && day == 15) return 1.0;

    // 30 Ağustos
    if (month == 8 && day == 30) return 1.0;

    // 29 Ekim (28 Ekim Arife)
    if (month == 10) {
      if (day == 28) return 0.5; // Yarım gün
      if (day == 29) return 1.0;
    }

    return 0.0;
  }
  static bool isRamazanMonth(int year, int month) {
    if (year == 2024) return month == 4;
    if (year == 2025) return month == 3 || month == 4; // March 30
    if (year == 2026) return month == 3;
    if (year == 2027) return month == 3;
    return false;
  }

  static bool isKurbanMonth(int year, int month) {
    if (year == 2024) return month == 6;
    if (year == 2025) return month == 6;
    if (year == 2026) return month == 5;
    if (year == 2027) return month == 5;
    return false;
  }
}
