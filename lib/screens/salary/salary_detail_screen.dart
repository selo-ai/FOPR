import 'package:flutter/material.dart';
import '../../models/salary_record.dart';
import '../../models/salary_settings.dart';
import '../../services/database_service.dart';
import '../../services/salary_service.dart'; // To access helper calculation methods for display
import 'package:intl/intl.dart';
import 'add_salary_record_screen.dart';

class SalaryDetailScreen extends StatelessWidget {
  final SalaryRecord record;
  final SalarySettings settings; // We need settings to display breakdowns correctly

  const SalaryDetailScreen({
    super.key,
    required this.record,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    // Re-calculate values for display (since we only stored totals in record)
    // Ideally, we'd store the breakdown or use a specialized class, but re-calc is fine for now
    
    // 1. Gross Breakdown
    final normalPay = record.normalHours * settings.hourlyGrossRate;
    final overtimePay = record.overtimeHours * settings.hourlyGrossRate * 2;
    final nightDiffPay = record.nightShiftHours * settings.hourlyGrossRate * 0.20;
    final weekendPay = record.weekendHours * settings.hourlyGrossRate * 1.0;
    final publicHolidayPay = record.publicHolidayHours * settings.hourlyGrossRate * 1.0;
    final annualLeavePay = record.annualLeaveDays * 7.5 * settings.hourlyGrossRate;
    
    double shiftAllowance = record.normalHours * settings.hourlyGrossRate * 0.10;
    
    final familyAllowance = (settings.childCount * settings.childAllowancePerChild) + settings.fuelAllowance;
    
    // 2. Legal Deductions Breakdown
    final sgk = SalaryService.calculateSGK(record.totalGrossPay);
    final unemployment = SalaryService.calculateUnemployment(record.totalGrossPay);
    final stampDuty = SalaryService.calculateStampDuty(record.totalGrossPay);
    // Income tax is the remainder of legal deductions
    final legalDeductionsTotal = sgk + unemployment + stampDuty; // + Income Tax
    // This is tricky because we didn't store income tax separately. 
    // We can deduce it: IncomeTax = totalGross - sgk - unemp - stamp - net - private
    // Wait, simpler: IncomeTax = (gross - net - private) - (sgk + unemp + stamp)
    // But we need to know Private Deductions first.
    
    double privateDeductions = 0;
    if (settings.hasUnion) privateDeductions += record.totalGrossPay * (settings.unionRate / 100);
    if (settings.hasBES) privateDeductions += record.totalGrossPay * 0.06;
    privateDeductions += settings.healthInsurance;
    privateDeductions += settings.educationFund;
    privateDeductions += settings.foundationDeduction;
    // Avans is technically a deduction from NET, not Gross, but in our logic it was subtracted to reach Pay-in-hand?
    // In SalaryService: netPay = gross - legal - private - avans.
    // So let's separate Avans from "Private Deductions" for display.
    
    final incomeTax = record.totalGrossPay - record.totalNetPay - privateDeductions - record.advanceAmount - sgk - unemployment - stampDuty;

    return Scaffold(
      appBar: AppBar(
        title: Text('${DateFormat('MMMM yyyy', 'tr_TR').format(DateTime(record.year, record.month))} Bordro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editRecord(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteRecord(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
            _buildSummaryCard(context, record),
            const SizedBox(height: 24),
            _buildSection('BRÜT ÖDEMELER', [
                _buildRow('Normal Çalışma', normalPay),
                if (overtimePay > 0) _buildRow('Fazla Mesai', overtimePay),
                if (nightDiffPay > 0) _buildRow('Gece Farkı', nightDiffPay),
                if (weekendPay > 0) _buildRow('Hafta Tatili', weekendPay),
                if (publicHolidayPay > 0) _buildRow('Genel Tatil', publicHolidayPay),
                if (annualLeavePay > 0) _buildRow('Yıllık İzin', annualLeavePay),
                if (record.otosanAllowance > 0) _buildRow('Otosan Katkısı', record.otosanAllowance),
                if (record.holidayAllowance > 0) _buildRow('Bayram Harçlığı', record.holidayAllowance),
                if (record.jobIndemnity > 0) _buildRow('Görev Tazminatı', record.jobIndemnity),
                if (record.tisAdvance > 0) _buildRow('TİS Ön Ödeme', record.tisAdvance),
                if (record.leaveAllowance > 0) _buildRow('İzin Harçlığı', record.leaveAllowance),
                if (record.tahsilAllowance > 0) _buildRow('Tahsil Yardımı', record.tahsilAllowance),
                if (record.shoeAllowance > 0) _buildRow('Ayakkabı Çeki', record.shoeAllowance),
                if (shiftAllowance > 0) _buildRow('Vardiya', shiftAllowance),
                if (record.bonusAmount > 0) _buildRow('İkramiye', record.bonusAmount),
                if (familyAllowance > 0) _buildRow('Sosyal Yardımlar', familyAllowance),
                const Divider(),
                _buildRow('TOPLAM BRÜT', record.totalGrossPay, isBold: true),
            ]),
            
            _buildSection('YASAL KESİNTİLER', [
                _buildRow('SGK Primi (%14)', sgk),
                _buildRow('İşsizlik Sig. (%1)', unemployment),
                _buildRow('Gelir Vergisi', incomeTax),
                _buildRow('Damga Vergisi', stampDuty),
                const Divider(),
                _buildRow('TOPLAM YASAL', sgk+unemployment+incomeTax+stampDuty, isBold: true),

            ]),

            _buildSection('ÖZEL KESİNTİLER', [
                if (settings.hasUnion) _buildRow('Sendika', settings.hourlyGrossRate * 7.5),
                if (settings.hasBES) _buildRow('Vakıf BES (%6)', record.totalGrossPay * 0.06),
                if (settings.hasHealthInsurance) _buildRow('Sağlık Sig. (ÖSS)', settings.ossPersonCount * settings.ossCostPerPerson),
                if (settings.hasExecution) _buildRow('İcra / Nafaka', settings.executionAmount),
                if (settings.educationFund > 0) _buildRow('Öğrenim Fonu', settings.educationFund),
                if (settings.foundationDeduction > 0) _buildRow('Vakıf Kesintisi', settings.foundationDeduction),
                if (record.advanceAmount > 0) _buildRow('Avans', record.advanceAmount, color: Colors.red),
                const Divider(),
                _buildRow('TOPLAM ÖZEL', privateDeductions + record.advanceAmount, isBold: true),
            ]),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, SalaryRecord record) {
      return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0,4),
                  )
              ]
          ),
          child: Column(
              children: [
                  const Text('ÖDENECEK NET TUTAR', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                      NumberFormat.currency(symbol: '₺', decimalDigits: 2, locale: 'tr_TR').format(record.totalNetPay),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
              ],
          ),
      );
  }

  Widget _buildSection(String title, List<Widget> children) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              ),
              Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(children: children),
              ),
              const SizedBox(height: 24),
          ],
      );
  }

  Widget _buildRow(String label, double value, {bool isBold = false, Color? color}) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
                  Text(
                      NumberFormat.currency(symbol: '₺', decimalDigits: 2, locale: 'tr_TR').format(value),
                      style: TextStyle(
                          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                          color: color ?? (isBold ? Colors.black : Colors.grey.shade700),
                      ),
                  ),
              ],
          ),
      );
  }

  Future<void> _editRecord(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSalaryRecordScreen(record: record),
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context, true); // Return true to trigger refresh in parent
    }
  }

  Future<void> _deleteRecord(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydı Sil'),
        content: const Text('Bu maaş kaydını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İPTAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('SİL'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await DatabaseService.deleteSalaryRecord(record.id);
      if (context.mounted) {
         Navigator.pop(context, true); // Return true to trigger refresh in parent
      }
    }
  }
}
