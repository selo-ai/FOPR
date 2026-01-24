
class SocialStandards {
  final String grup;
  final Map<String, double> amounts;
  final Map<String, HealthInsuranceRates> healthInsurance;

  SocialStandards({
    required this.grup,
    required this.amounts,
    required this.healthInsurance,
  });

  factory SocialStandards.fromJson(Map<String, dynamic> json) {
    // Convert all values in anlasma_tutarlar to double
    final rawAmounts = json['anlasma_tutarlar'] as Map<String, dynamic>;
    final amounts = <String, double>{};
    
    rawAmounts.forEach((key, value) {
      if (value is num) {
        amounts[key] = value.toDouble();
      }
    });

    // Parse Health Insurance
    final healthMap = <String, HealthInsuranceRates>{};
    if (json.containsKey('saglik_sigortasi')) {
        final rawHealth = json['saglik_sigortasi'] as Map<String, dynamic>;
        
        if (rawHealth.containsKey('tamamlayici_saglik_sigortasi')) {
            healthMap['tss'] = HealthInsuranceRates.fromJson(rawHealth['tamamlayici_saglik_sigortasi']);
        }
        if (rawHealth.containsKey('ozel_saglik_sigortasi')) {
            healthMap['oss'] = HealthInsuranceRates.fromJson(rawHealth['ozel_saglik_sigortasi']);
        }
    }

    return SocialStandards(
      grup: json['grup'] ?? '',
      amounts: amounts,
      healthInsurance: healthMap,
    );
  }

  double getAmount(String key) => amounts[key] ?? 0.0;
}

class HealthInsuranceRates {
  final double spouse;
  final double child;

  HealthInsuranceRates({required this.spouse, required this.child});

  factory HealthInsuranceRates.fromJson(Map<String, dynamic> json) {
    return HealthInsuranceRates(
      spouse: (json['es'] as num?)?.toDouble() ?? 0.0,
      child: (json['cocuklar'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
