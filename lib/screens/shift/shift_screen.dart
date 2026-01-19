import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/shift_type.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  ShiftType? _currentShift;
  DateTime _referenceDate = DateTime.now();
  DateTime _targetDate = DateTime.now();
  ShiftType? _resultShift;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vardiya Hesaplama'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Current shift selection
            _buildSectionTitle('Bu Hafta Hangi Vardiyadasın?'),
            const SizedBox(height: 12),
            _buildShiftSelector(),
            const SizedBox(height: 24),

            // Step 2: Target date selection
            _buildSectionTitle('Hangi Tarihi Hesaplamak İstiyorsun?'),
            const SizedBox(height: 12),
            _buildDateSelector(),
            const SizedBox(height: 32),

            // Calculate button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _currentShift != null ? _calculateShift : null,
                child: const Text('Hesapla', style: TextStyle(fontSize: 16)),
              ),
            ),

            // Result
            if (_resultShift != null) ...[
              const SizedBox(height: 32),
              _buildResultCard(),
            ],

            // Info card at bottom
            const SizedBox(height: 32),
            _buildInfoCard(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 20),
              const SizedBox(width: 8),
              Text(
                'Vardiya Döngüsü',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Gece → Akşam → Sabah → Gece...',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          Text(
            'Her vardiya 1 hafta sürer. Pazar tatil.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildShiftSelector() {
    return Row(
      children: ShiftType.values.map((type) {
        final isSelected = _currentShift == type;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type != ShiftType.evening ? 8 : 0,
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _currentShift = type;
                  _resultShift = null;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2196F3).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2196F3)
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(type.assetPath, width: 48, height: 48),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? const Color(0xFF2196F3) : null,
                      ),
                    ),
                    Text(
                      type.timeRange,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _pickTargetDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 24, color: Color(0xFF2196F3)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('d MMMM yyyy', 'tr_TR').format(_targetDate),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    DateFormat('EEEE', 'tr_TR').format(_targetDate),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final isSunday = _targetDate.weekday == DateTime.sunday;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSunday
              ? [Colors.green.shade400, Colors.green.shade600]
              : [const Color(0xFF2196F3), const Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(_targetDate),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          if (isSunday) ...[
            const Text('🏖️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            const Text(
              'TATİL',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Pazar günleri çalışma yok',
              style: TextStyle(color: Colors.white70),
            ),
          ] else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(_resultShift!.assetPath, width: 100, height: 100),
            ),
            const SizedBox(height: 8),
            Text(
              '${_resultShift!.displayName} Vardiyası',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _resultShift!.timeRange,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null) {
      setState(() {
        _targetDate = picked;
        _resultShift = null;
      });
    }
  }

  void _calculateShift() {
    if (_currentShift == null) return;

    // Pazar günü kontrolü
    if (_targetDate.weekday == DateTime.sunday) {
      setState(() {
        _resultShift = _currentShift; // Sadece tatil göstermek için
      });
      return;
    }

    // Referans hafta numarası (bu hafta)
    final referenceWeek = _getWeekNumber(_referenceDate);
    // Hedef hafta numarası
    final targetWeek = _getWeekNumber(_targetDate);
    
    // Hafta farkı
    final weekDiff = targetWeek - referenceWeek;
    
    // Yeni vardiya indeksi hesapla
    // Döngü: Gece(0) → Akşam(1) → Sabah(2) → Gece(0)
    final currentIndex = _currentShift!.cycleIndex;
    var newIndex = (currentIndex + weekDiff) % 3;
    if (newIndex < 0) newIndex += 3;
    
    setState(() {
      _resultShift = ShiftTypeExtension.fromCycleIndex(newIndex);
    });
  }

  /// ISO hafta numarası hesapla
  int _getWeekNumber(DateTime date) {
    // Yılın ilk Pazartesi gününü bul
    final jan1 = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(jan1).inDays;
    
    // ISO hafta numarası
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}
