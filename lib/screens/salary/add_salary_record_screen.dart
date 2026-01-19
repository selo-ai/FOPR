import 'package:flutter/material.dart';
import '../../models/salary_record.dart';
import '../../models/salary_settings.dart';
import '../../services/database_service.dart';
import '../../services/salary_service.dart';
import 'package:intl/intl.dart';

class AddSalaryRecordScreen extends StatefulWidget {
  final SalaryRecord? record;

  const AddSalaryRecordScreen({super.key, this.record});

  @override
  State<AddSalaryRecordScreen> createState() => _AddSalaryRecordScreenState();
}

class _AddSalaryRecordScreenState extends State<AddSalaryRecordScreen> {
  late DateTime _selectedDate;
  late TextEditingController _normalHoursController;
  late TextEditingController _overtimeHoursController; // Auto-filled but editable
  late TextEditingController _nightShiftHoursController;
  late TextEditingController _weekendHoursController;
  late TextEditingController _bonusController;
  late TextEditingController _advanceController;

  bool _isLoading = true;
  SalarySettings? _settings;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    if (widget.record != null) {
      _selectedDate = DateTime(widget.record!.year, widget.record!.month);
    }
    
    _normalHoursController = TextEditingController();
    _overtimeHoursController = TextEditingController();
    _nightShiftHoursController = TextEditingController();
    _weekendHoursController = TextEditingController();
    _bonusController = TextEditingController();
    _advanceController = TextEditingController();

    _loadData();
  }

  Future<void> _loadData() async {
    _settings = await DatabaseService.getSalarySettings();
    
    if (widget.record != null) {
      final r = widget.record!;
      _normalHoursController.text = r.normalHours.toString();
      _overtimeHoursController.text = r.overtimeHours.toString();
      _nightShiftHoursController.text = r.nightShiftHours.toString();
      _weekendHoursController.text = r.weekendHours.toString();
      _bonusController.text = r.bonusAmount.toString();
      _advanceController.text = r.advanceAmount.toString();
    } else {
      // Default values for new record
      _normalHoursController.text = '187.5'; // 30 days default
      await _fetchAutoOvertime(_selectedDate.year, _selectedDate.month);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchAutoOvertime(int year, int month) async {
    // Mesai modülünden o ayın toplam mesaisini çek
    final monthlyOvertime = DatabaseService.getMonthlyTotal(year, month);
    _overtimeHoursController.text = monthlyOvertime.toString();
    
    // TODO: Vardiya modülünden gece saatlerini çekmek mümkünse buraya eklenebilir
  }

  Future<void> _selectDate(BuildContext context) async {
    // Only year and month picker ideally, but standard picker is fine for now
    // We pick a date, but only use Month/Year
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // Refresh auto-suggested values for the new month
      if (widget.record == null) {
        await _fetchAutoOvertime(picked.year, picked.month);
      }
    }
  }

  Future<void> _save() async {
    if (_settings == null) return;

    final normalHours = double.tryParse(_normalHoursController.text) ?? 0;
    final overtimeHours = double.tryParse(_overtimeHoursController.text) ?? 0;
    final nightHours = double.tryParse(_nightShiftHoursController.text) ?? 0;
    final weekendHours = double.tryParse(_weekendHoursController.text) ?? 0;
    final bonus = double.tryParse(_bonusController.text) ?? 0;
    final advance = double.tryParse(_advanceController.text) ?? 0;

    SalaryRecord record;
    if (widget.record != null) {
      record = widget.record!;
      // Update fields
      record.year = _selectedDate.year;
      record.month = _selectedDate.month;
      record.normalHours = normalHours;
      record.overtimeHours = overtimeHours;
      record.nightShiftHours = nightHours;
      record.weekendHours = weekendHours;
      record.bonusAmount = bonus;
      record.advanceAmount = advance;
    } else {
        // Check if record already exists for this month?
        final existing = DatabaseService.getSalaryRecord(_selectedDate.year, _selectedDate.month);
        if (existing != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bu ay için zaten bir kayıt var!')),
            );
            return;
        }

      record = SalaryRecord.create(
        year: _selectedDate.year,
        month: _selectedDate.month,
        normalHours: normalHours,
        overtimeHours: overtimeHours,
        nightShiftHours: nightHours,
        weekendHours: weekendHours,
        bonusAmount: bonus,
        advanceAmount: advance,
      );
    }

    // For new records, we must save to DB first to ensure it's in the Hive box
    // because SalaryService.calculateAndSave calls record.save()
    if (widget.record == null) {
        await DatabaseService.saveSalaryRecord(record);
    }
    
    await SalaryService.calculateAndSave(record, _settings!);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record != null ? 'Maaş Kaydını Düzenle' : 'Yeni Maaş Kaydı'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarih Seçimi
          InkWell(
            onTap: widget.record == null ? () => _selectDate(context) : null, // Prevent date change on edit for simplicity
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month),
                  const SizedBox(width: 16),
                  Text(
                    DateFormat('MMMM yyyy', 'tr_TR').format(_selectedDate),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (widget.record == null) const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          const Text('Çalışma Saatleri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          
          Row(children: [
             Expanded(child: _buildField('Normal Saat', _normalHoursController)),
             const SizedBox(width: 16),
             Expanded(child: _buildField('Fazla Mesai', _overtimeHoursController, suffix: '(Oto)')),
          ]),
          
          Row(children: [
             Expanded(child: _buildField('Gece (Saat)', _nightShiftHoursController)),
             const SizedBox(width: 16),
             Expanded(child: _buildField('Hafta Tatili', _weekendHoursController)),
          ]),
          
          const SizedBox(height: 24),
          const Text('Ek Ödeme / Kesinti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          
          Row(children: [
             Expanded(child: _buildField('İkramiye (TL)', _bonusController)),
             const SizedBox(width: 16),
             Expanded(child: _buildField('Avans (TL)', _advanceController)),
          ]),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
            ),
            child: const Text('HESAPLA VE KAYDET', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
