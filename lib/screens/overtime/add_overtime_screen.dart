import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/overtime.dart';
import '../../services/database_service.dart';

class AddOvertimeScreen extends StatefulWidget {
  final DateTime? initialDate;

  const AddOvertimeScreen({super.key, this.initialDate});

  @override
  State<AddOvertimeScreen> createState() => _AddOvertimeScreenState();
}

class _AddOvertimeScreenState extends State<AddOvertimeScreen> {
  late DateTime _selectedDate;
  double? _selectedHours;
  final _customHoursController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isCustom = false;

  final List<double> _quickHours = [2, 4, 7.5];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _customHoursController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesai Ekle'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Date selector
          Text(
            'Tarih',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          _buildDateSelector(),
          const SizedBox(height: 32),

          // Quick hour buttons
          Text(
            'Mesai Süresi',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          _buildQuickHourButtons(),
          const SizedBox(height: 16),

          // Custom input
          _buildCustomInput(),
          const SizedBox(height: 32),

          // Note
          Text(
            'Not (Opsiyonel)',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: 'Mesai ile ilgili not...',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 40),

          // Save button
          ElevatedButton(
            onPressed: _canSave ? _save : null,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final dateStr = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(_selectedDate);
    final isToday = _isSameDay(_selectedDate, DateTime.now());

    return Card(
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isToday)
                      Text(
                        'Bugün',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickHourButtons() {
    return Row(
      children: _quickHours.map((hours) {
        final isSelected = !_isCustom && _selectedHours == hours;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: hours == _quickHours.last ? 0 : 8,
            ),
            child: _QuickHourButton(
              hours: hours,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedHours = hours;
                  _isCustom = false;
                  _customHoursController.clear();
                });
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Checkbox(
              value: _isCustom,
              onChanged: (value) {
                setState(() {
                  _isCustom = value ?? false;
                  if (_isCustom) {
                    _selectedHours = null;
                  }
                });
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _customHoursController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Özel saat girin',
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                ),
                onChanged: (value) {
                  setState(() {
                    _isCustom = true;
                    _selectedHours = double.tryParse(value.replaceAll(',', '.'));
                  });
                },
              ),
            ),
            Text(
              'saat',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSave {
    if (_isCustom) {
      final value = double.tryParse(_customHoursController.text.replaceAll(',', '.'));
      return value != null && value > 0;
    }
    return _selectedHours != null && _selectedHours! > 0;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _save() async {
    final hours = _isCustom
        ? double.parse(_customHoursController.text.replaceAll(',', '.'))
        : _selectedHours!;

    // Check quota before saving
    final settings = DatabaseService.getSettings();
    final monthlyQuota = settings.monthlyQuota;
    final currentMonthlyTotal = DatabaseService.getMonthlyTotal(
      _selectedDate.year,
      _selectedDate.month,
    );
    final newTotal = currentMonthlyTotal + hours;
    final wasUnderQuota = monthlyQuota > 0 && currentMonthlyTotal <= monthlyQuota;
    final willExceedQuota = monthlyQuota > 0 && newTotal > monthlyQuota;

    final overtime = Overtime(
      id: const Uuid().v4(),
      date: _selectedDate,
      hours: hours,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      createdAt: DateTime.now(),
    );

    await DatabaseService.addOvertime(overtime);
    
    if (mounted) {
      // Show quota exceeded warning if this save caused the quota to be exceeded
      if (wasUnderQuota && willExceedQuota) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Aylık mesai kotası aşıldı!\n${newTotal.toStringAsFixed(1)} / ${monthlyQuota.toStringAsFixed(1)} saat',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFB71C1C),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      Navigator.pop(context);
    }
  }
}

class _QuickHourButton extends StatelessWidget {
  final double hours;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickHourButton({
    required this.hours,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? null
                : Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Text(
                hours.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.headlineMedium?.color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'saat',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? Colors.white70
                          : Theme.of(context).textTheme.labelMedium?.color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
