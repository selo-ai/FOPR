import 'package:flutter/material.dart';
import '../../models/salary_record.dart';
import '../../services/database_service.dart';
import 'salary_settings_screen.dart';
import 'add_salary_record_screen.dart';
import 'salary_detail_screen.dart';
import 'package:intl/intl.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  List<SalaryRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkDisclaimer());
  }

  void _loadRecords() {
    setState(() {
      _records = DatabaseService.getAllSalaryRecords();
    });
  }

  Future<void> _addRecord() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSalaryRecordScreen()),
    );
    if (result == true) {
      _loadRecords();
    }
  }

  Future<void> _openDetail(SalaryRecord record) async {
    // We need settings for the detail view
    final settings = await DatabaseService.getSalarySettings();
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SalaryDetailScreen(record: record, settings: settings)),
    );
  }



  Future<void> _checkDisclaimer() async {
      final settings = DatabaseService.getSettings();
      
      // 1. settings Reminder (Conditional)
      if (!settings.salarySettingsReminderShown) {
          bool doNotShowAgain = false;
          await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Row(
                        children: [
                           Icon(Icons.settings, color: Colors.blue),
                           SizedBox(width: 10),
                           Flexible(child: Text("Ayarlar Hatırlatması")),
                        ],
                    ),
                    content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            const Text(
                                "Doğru maaş hesaplaması için lütfen 'Ayarlar' sayfasındaki bilgilerin eksiksiz ve güncel olduğundan emin olun.",
                                style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Checkbox(
                                  value: doNotShowAgain, 
                                  onChanged: (val) {
                                    setState(() => doNotShowAgain = val ?? false);
                                  }
                                ),
                                const Expanded(child: Text("Bir daha gösterme")),
                              ],
                            )
                        ],
                    ),
                    actions: [
                        TextButton(
                            onPressed: () async {
                                if (doNotShowAgain) {
                                  settings.salarySettingsReminderShown = true;
                                  await settings.save();
                                }
                                if (context.mounted) Navigator.pop(context);
                            },
                            child: const Text("TAMAM"),
                        )
                    ],
                  );
                }
              ),
          );
      }

      if (!mounted) return;

      // 2. Accuracy Warning (Always Shown)
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
              title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                       Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                       SizedBox(width: 10),
                       Text("UYARI", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
              ),
              content: const Text(
                  "Bu modüldeki hesaplamalar yaklaşık değerlerdir ve bilgilendirme amaçlıdır.\n\n"
                  "Resmi bordronuzla ücret farkları veya vergi dilimi kaynaklı sapmalar olabilir. Kesin sonuçlar için lütfen muhasebe departmanınızla görüşün.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("ANLADIM"),
                  )
              ],
          ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maaş Takip'),
      ),
      body: Column(
        children: [
          // Prominent Settings Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SalarySettingsScreen()),
                ).then((_) => _loadRecords());
              },
              icon: const Icon(Icons.settings),
              label: const Text('MAAŞ AYARLARINI DÜZENLE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          Expanded(
            child: _records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz maaş kaydı yok',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _addRecord,
                        icon: const Icon(Icons.add),
                        label: const Text('Maaş Hesapla'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    final date = DateTime(record.year, record.month);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Text(
                            DateFormat('MMM', 'tr_TR').format(date).toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          DateFormat('MMMM yyyy', 'tr_TR').format(date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Net: ${NumberFormat.currency(symbol: '₺', decimalDigits: 2, locale: 'tr_TR').format(record.totalNetPay)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openDetail(record),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecord,
        child: const Icon(Icons.add),
      ),
    );
  }
}
