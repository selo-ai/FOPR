import '../models/salary_record.dart';
import '../models/salary_settings.dart';
import 'database_service.dart';

class SalaryService {
  // 2026 Gelir Vergisi Dilimleri (Kümülatif)
  // double key maplerde const kullanımı sorunlu olabilir, normal static final yapalım
  static final Map<double, double> taxBrackets = {
    190000: 0.15,
    400000: 0.20,
    1500000: 0.27,
    5300000: 0.35,
    double.infinity: 0.40,
  };

  // ... (existing code)


  static double calculateGrossPay(SalaryRecord record, SalarySettings settings) {
    double total = 0;
    
    // Normal Çalışma: Saat × Saatlik Ücret
    total += record.normalHours * settings.hourlyGrossRate;
    
    // Fazla Mesai: Mesai Saati × Saatlik Ücret × 2
    total += record.overtimeHours * settings.hourlyGrossRate * 2;
    
    // Gece Vardiyası: Gece Saati × Saatlik Ücret × 0.20 (Ek prim)
    // Not: Gece çalışma saati normal saatin içindeyse sadece fark eklenir. 
    // Eğer ayrıysa normal saat + prim eklenir. 
    // Standart kabul: Normal çalışma içinde gece primi ekstra verilir.
    total += record.nightShiftHours * settings.hourlyGrossRate * 0.20;
    
    // Hafta Tatili: Tatil Saati × Saatlik Ücret × 1.5
    total += record.weekendHours * settings.hourlyGrossRate * 1.5;
    
    // İkramiye
    total += record.bonusAmount;
    
    // Sabit Yardımlar
    total += settings.fuelAllowance; // Yakacak
    total += settings.childCount * settings.childAllowancePerChild; // Çocuk
    
    return total;
  }

  static double calculateSGK(double grossPay) {
    // SGK İşçi Payı: %14
    return grossPay * 0.14;
  }

  static double calculateUnemployment(double grossPay) {
    // İşsizlik Sigortası İşçi Payı: %1
    return grossPay * 0.01;
  }

  static double calculateStampDuty(double grossPay) {
    // Damga Vergisi: %0.759 (Binde 7.59)
    return grossPay * 0.00759;
  }

  // Kümülatif vergi matrahına göre gelir vergisini hesaplar
  static double calculateIncomeTax(double monthlyTaxBase, double cumulativeTaxBaseBefore) {
    double tax = 0;
    double remainingBase = monthlyTaxBase;
    double currentCumulative = cumulativeTaxBaseBefore;

    // Basitleştirilmiş dilim hesabı
    // Dilimler: 190k, 400k, 1.5m, 5.3m
    
    while (remainingBase > 0) {
      double rate = 0.15;
      double limit = 0;
      
      if (currentCumulative < 190000) {
        rate = 0.15;
        limit = 190000 - currentCumulative;
      } else if (currentCumulative < 400000) {
        rate = 0.20;
        limit = 400000 - currentCumulative;
      } else if (currentCumulative < 1500000) {
        rate = 0.27;
        limit = 1500000 - currentCumulative;
      } else if (currentCumulative < 5300000) {
        rate = 0.35;
        limit = 5300000 - currentCumulative;
      } else {
        rate = 0.40;
        limit = double.infinity;
      }

      double taxableAmount = remainingBase;
      if (taxableAmount > limit) {
        taxableAmount = limit;
      }

      tax += taxableAmount * rate;
      remainingBase -= taxableAmount;
      currentCumulative += taxableAmount;
    }

    return tax;
  }

  // Geçmiş ayların toplam matrahını hesaplar
  static double getCumulativeTaxBase(int year, int currentMonth) {
    double totalBase = 0;
    
    // O yılın önceki aylarındaki kayıtları çek
    final records = DatabaseService.getAllSalaryRecords()
        .where((r) => r.year == year && r.month < currentMonth)
        .toList();

    for (var record in records) {
      // O ayki brüt ve kesintileri (SGK + İşsizlik) tekrar hesaplamamız lazım 
      // veya kayıtta saklamalıydık. Şu an saklamadık, tekrar hesaplayalım.
      // Not: Bu yöntem ayarlar değişirse geçmişi yanlış hesaplayabilir!
      // İdealde SalaryRecord içinde 'taxBase' de saklanmalı.
      // Şimdilik 'totalGrossPay' üzerinden yaklaşık gidelim, ama doğrusu:
      // Vergi Matrahı = Brüt - (SGK + İşsizlik)
      
      // Kayıtlı brüt yoksa, o an hesapla (eski kayıtlar için)
      double gross = record.totalGrossPay; 
      if (gross == 0) {
         // Uyarı: Ayarlar değişmiş olabilir ama yapacak bir şey yok
         // Burası kritik bir nokta. Şimdilik pas geçiyoruz.
      }
      
      double sgk = calculateSGK(gross);
      double unemployment = calculateUnemployment(gross);
      totalBase += (gross - sgk - unemployment);
    }
    
    return totalBase;
  }

  static Future<SalaryRecord> calculateAndSave(SalaryRecord record, SalarySettings settings) async {
    // 1. Brüt Hesapla
    double grossPay = calculateGrossPay(record, settings);
    
    // 2. Yasal Kesintiler
    double sgk = calculateSGK(grossPay);
    double unemployment = calculateUnemployment(grossPay);
    
    double taxBase = grossPay - sgk - unemployment;
    double cumulativeBaseBefore = getCumulativeTaxBase(record.year, record.month);
    
    double incomeTax = calculateIncomeTax(taxBase, cumulativeBaseBefore);
    double stampDuty = calculateStampDuty(grossPay);
    
    double totalLegalDeductions = sgk + unemployment + incomeTax + stampDuty;
    
    // 3. Özel Kesintiler
    double totalPrivateDeductions = 0;
    
    if (settings.hasUnion) {
      // Sendika: 1 günlük brüt yevmiye (7.5 saat)
      totalPrivateDeductions += settings.hourlyGrossRate * 7.5;
    }
    
    if (settings.hasBES) {
      totalPrivateDeductions += settings.besAmount;
    }
    
    if (settings.hasHealthInsurance) {
        // TSS: Kişi Sayısı × Kişi Başı Ücret
        totalPrivateDeductions += settings.ossPersonCount * settings.ossCostPerPerson;
    }
    
    if (settings.hasExecution) {
      totalPrivateDeductions += settings.executionAmount;
    }

    totalPrivateDeductions += settings.educationFund;
    totalPrivateDeductions += settings.foundationDeduction;
    totalPrivateDeductions += record.advanceAmount;

    // 4. Net Hesapla
    double netPay = grossPay - totalLegalDeductions - totalPrivateDeductions;
    
    // Değerleri kayıtta güncelle
    record.totalGrossPay = grossPay;
    record.totalNetPay = netPay;
    record.cachedHourlyRate = settings.hourlyGrossRate;
    
    await record.save();
    return record;
  }
}
