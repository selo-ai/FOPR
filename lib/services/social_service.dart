import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/social_standards.dart';
import '../utils/holiday_utils.dart';

class SocialService {
  static SocialStandards? _standards;

  static Future<void> init() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/sosyal.json');
      final jsonMap = json.decode(jsonString);
      _standards = SocialStandards.fromJson(jsonMap);
    } catch (e) {
      print('SocialService Init Error: $e');
    }
  }

  static double getAmount(String key) {
    if (_standards == null) return 0.0;
    return _standards!.getAmount(key);
  }

  // --- Convenience Getters based on sosyal.json keys ---

  static double get shoeAmount => getAmount('ayakkabi');
  static double get leaveAmount => getAmount('yillik_izin');
  static double get fuelAmount => getAmount('yakacak');
  static double get childAmount => getAmount('cocuk');
  static double get foodAmount => getAmount('yemek'); // Monthly/Daily? Usually daily but check JSON. JSON says 193.76, likely daily.

  // --- Complex Getters ---

  /// Returns 0 if none.
  static double getHolidayAllowance(int year, int month) {
    // Check if Ramazan or Kurban is in this month
    // We need a way to check specific Islamic holidays.
    // HolidayUtils checks generic holidays.
    // For now, let's assume HolidayUtils validates dates.
    // But does HolidayUtils distinguish Ramazan vs Kurban?
    // Looking at HolidayUtils: it has _holidays list.
    // Let's rely on standard Hijri calculation or hardcoded dates if HolidayUtils doesn't support specific names.
    // However, simply:
    // If the month contains Ramazan Start date?
    // Actually, "Bayram Harçlığı" is paid BEFORE the holiday usually.
    // Let's ask HolidayUtils if it knows about "Ramazan Bayramı" or "Kurban Bayramı".
    
    // Fallback logic: check hardcoded approximate dates or if user requests.
    // For simplicity given the scope: returning 0 here and letting UI logic handle specific month check using standard dates if possible.
    // Better: let's map known dates for 2024-2026.
    
    bool isRamazan = HolidayUtils.isRamazanMonth(year, month);
    bool isKurban = HolidayUtils.isKurbanMonth(year, month);

    if (isKurban) return getAmount('kurban');
    if (isRamazan) return getAmount('ramazan');
    
    return 0.0;
  }

  static double getEducationAmount(String level) {
    // level: 'anasinifi', 'ilkokul', 'ortaokul', 'lise', 'yuksek'
    return getAmount('ogrenim_$level');
  }

  static double getHealthInsuranceSpouseAmount(String type) {
    // type: 'oss' or 'tss'
    if (_standards == null) return 0.0;
    return _standards!.healthInsurance[type]?.spouse ?? 0.0;
  }

  static double getHealthInsuranceChildAmount(String type) {
    if (_standards == null) return 0.0;
    return _standards!.healthInsurance[type]?.child ?? 0.0;
  }
}
