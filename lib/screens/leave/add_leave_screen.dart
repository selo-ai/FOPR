import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/leave.dart';
import '../../models/leave_type.dart';
import '../../services/database_service.dart';

class AddLeaveScreen extends StatefulWidget {
  final DateTime? initialDate;

  const AddLeaveScreen({super.key, this.initialDate});

  @override
  State<AddLeaveScreen> createState() => _AddLeaveScreenState();
}

class _AddLeaveScreenState extends State<AddLeaveScreen> {
  LeaveType _selectedType = LeaveType.annual;
  late DateTime _startDate;
  late DateTime _endDate;
  double _hours = 4.0; // Ücretsiz izin için saat
  final _noteController = TextEditingController();
  double _calculatedDays = 1;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDate ?? DateTime.now();
    _endDate = _startDate;
    _calculateDays();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _calculateDays() {
    if (_selectedType.isHourBased) {
      // Ücretsiz izin - saate göre gün hesapla
      _calculatedDays = _hours / 8.0;
    } else if (_selectedType.fixedDays != null) {
      // Sabit süreli izinler
      _calculatedDays = _selectedType.fixedDays!.toDouble();
      // Bitiş tarihini otomatik ayarla
      _endDate = _startDate.add(Duration(days: _selectedType.fixedDays! - 1));
    } else {
      // Tarih aralığına göre hesapla
      _calculatedDays = Leave.calculateDays(
        _startDate,
        _endDate,
        _selectedType.includesWeekends,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İzin Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leave type selector
            Text(
              'İzin Türü',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            _buildLeaveTypeSelector(),
            const SizedBox(height: 24),

            // Hours input (for unpaid leave)
            if (_selectedType.isHourBased) ...[
              Text(
                'Saat',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              _buildHoursSelector(),
              const SizedBox(height: 24),
            ],

            // Date selector (not for hour-based)
            if (!_selectedType.isHourBased) ...[
              Text(
                _selectedType.fixedDays != null ? 'Başlangıç Tarihi' : 'Tarih Aralığı',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              _buildDateSelector(),
              const SizedBox(height: 24),
            ],

            // Calculated days display
            _buildDaysDisplay(),
            const SizedBox(height: 24),

            // Note
            Text(
              'Not (Opsiyonel)',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'İzin ile ilgili not...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            // Quota warning
            if (_selectedType.deductsFromQuota) ...[
              const SizedBox(height: 24),
              _buildQuotaWarning(),
            ],

            // Save button
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Kaydet', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveTypeSelector() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: LeaveType.values.map((type) {
        final isSelected = type == _selectedType;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedType = type;
              _endDate = _startDate;
            });
            _calculateDays();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(type.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  type.displayName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHoursSelector() {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _hours,
            min: 1,
            max: 8,
            divisions: 7,
            label: '${_hours.toInt()} saat',
            onChanged: (value) {
              _hours = value;
              _calculateDays();
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_hours.toInt()} saat',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    final hasFixedDays = _selectedType.fixedDays != null;

    return Column(
      children: [
        // Start date
        InkWell(
          onTap: () => _pickDate(isStart: true),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasFixedDays ? 'Başlangıç' : 'Başlangıç',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(_startDate),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        if (!hasFixedDays) ...[
          const SizedBox(height: 12),
          // End date
          InkWell(
            onTap: () => _pickDate(isStart: false),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bitiş',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(_endDate),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDaysDisplay() {
    String label;
    if (_selectedType.isHourBased) {
      label = 'Hesaplanan süre: ${_calculatedDays.toStringAsFixed(1)} gün (${_hours.toInt()} saat)';
    } else if (_selectedType.includesWeekends) {
      label = 'Toplam süre: ${_calculatedDays.toInt()} gün (hafta sonu dahil)';
    } else {
      label = 'İş günü: ${_calculatedDays.toInt()} gün (hafta sonu hariç)';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2196F3)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaWarning() {
    final remaining = DatabaseService.getRemainingAnnualLeaveDays(DateTime.now().year);
    final afterThis = remaining - _calculatedDays;
    
    if (afterThis < 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Bu izin sonrası kotanız ${afterThis.abs().toStringAsFixed(0)} gün eksi olacak!',
                style: const TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.beach_access, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bu izin sonrası ${afterThis.toStringAsFixed(0)} gün kalacak',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
      _calculateDays();
    }
  }

  void _save() {
    if (_calculatedDays <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçersiz izin süresi')),
      );
      return;
    }

    final leave = Leave(
      id: const Uuid().v4(),
      type: _selectedType,
      startDate: _startDate,
      endDate: _selectedType.isHourBased ? _startDate : _endDate,
      days: _calculatedDays,
      hours: _selectedType.isHourBased ? _hours : null,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      createdAt: DateTime.now(),
    );

    DatabaseService.addLeave(leave);
    Navigator.pop(context);
  }
}
