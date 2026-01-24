import 'package:hive/hive.dart';

part 'salary_settings.g.dart';

@HiveType(typeId: 6)
class SalarySettings extends HiveObject {
  @HiveField(0)
  double hourlyGrossRate;

  @HiveField(1)
  double weeklyWorkHours;

  @HiveField(2)
  int childCount;

  @HiveField(3)
  double childAllowancePerChild;

  @HiveField(4)
  bool hasUnion;

  @HiveField(5)
  double unionRate;

  @HiveField(6)
  bool hasBES;

  @HiveField(7)
  double besAmount;

  @HiveField(8)
  double fuelAllowance;

  // Eski healthInsurance field'ı geriye dönük uyumluluk için tutuyoruz ama kullanılmayacak
  // veya toplam tutarı tutmak için de kullanılabilir.
  // Yeni mantıkta hesaplayıp buraya yazabiliriz veya getter kullanabiliriz.
  // Hive'da field silmek sorun olmaz, index kaydırmamak şart.
  @HiveField(9)
  double healthInsurance;

  @HiveField(10)
  double educationFund;

  @HiveField(11)
  double foundationDeduction;

  @HiveField(12, defaultValue: false)
  bool hasHealthInsurance;

  @HiveField(13, defaultValue: 0)
  int ossPersonCount;

  @HiveField(14, defaultValue: 0.0)
  double ossCostPerPerson;

  @HiveField(15, defaultValue: 'tss')
  String healthInsuranceType; // 'tss' or 'oss'

  @HiveField(16, defaultValue: false)
  bool healthInsuranceHasSpouse;

  @HiveField(17, defaultValue: 0)
  int healthInsuranceChildCount;

  @HiveField(18, defaultValue: false)
  bool hasExecution;

  @HiveField(19, defaultValue: 0.0)
  double executionAmount;

  @HiveField(20, defaultValue: true)
  bool hasShiftAllowance;

  SalarySettings({
    this.hourlyGrossRate = 0.0,
    this.weeklyWorkHours = 37.5,
    this.childCount = 0,
    this.childAllowancePerChild = 0.0,
    this.hasUnion = false,
    this.unionRate = 0.0,
    this.hasBES = false,
    this.besAmount = 0.0,
    this.fuelAllowance = 0.0,
    this.healthInsurance = 0.0,
    this.educationFund = 0.0,
    this.foundationDeduction = 0.0,
    this.hasHealthInsurance = false,
    this.ossPersonCount = 0,
    this.ossCostPerPerson = 0.0,
    this.hasExecution = false,
    this.executionAmount = 0.0,
    this.healthInsuranceType = 'tss',
    this.healthInsuranceHasSpouse = false,
    this.healthInsuranceChildCount = 0,
    this.hasShiftAllowance = true,
  });
}
