import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/shift_type.dart';
import '../services/shift_calendar_service.dart';

/// Ana ekranda gösterilecek vardiya takvimi widget'ı
class ShiftCalendarWidget extends StatefulWidget {
  const ShiftCalendarWidget({super.key});

  @override
  State<ShiftCalendarWidget> createState() => _ShiftCalendarWidgetState();
}

class _ShiftCalendarWidgetState extends State<ShiftCalendarWidget> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarData = ShiftCalendarService.getMonthCalendar(
      _currentMonth.year,
      _currentMonth.month,
    );

    // Haftanın başlangıç günü için boşluk hesapla (Pazartesi = 1)
    final firstDayWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    final leadingEmptyDays = firstDayWeekday - 1; // Pazartesi = 0 boşluk

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header: Ay navigasyonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormat('MMMM yyyy', 'tr_TR').format(_currentMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Hafta günleri başlıkları
            Row(
              children: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: day == 'Paz' ? Colors.red : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Takvim grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: leadingEmptyDays + calendarData.length,
              itemBuilder: (context, index) {
                // Baştaki boş günler
                if (index < leadingEmptyDays) {
                  return const SizedBox();
                }

                final dayData = calendarData[index - leadingEmptyDays];
                return _buildDayCell(dayData);
              },
            ),

            const SizedBox(height: 12),
            
            // Legend
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(ShiftDay dayData) {
    final isToday = dayData.isToday;
    final isSunday = dayData.isSunday;
    final isHoliday = dayData.isPublicHoliday;

    Color backgroundColor;
    Color textColor = Colors.black87;
    
    if (isSunday) {
      backgroundColor = Colors.grey.shade300;
      textColor = Colors.red.shade400;
    } else {
      switch (dayData.shiftType) {
        case ShiftType.night:
          backgroundColor = Colors.indigo.shade200;
          break;
        case ShiftType.morning:
          backgroundColor = Colors.amber.shade200;
          break;
        case ShiftType.evening:
          backgroundColor = Colors.orange.shade200;
          break;
        default:
          backgroundColor = Colors.grey.shade100;
      }
    }

    // Bayramlarda metin rengini kırmızı yap veya ek gösterge ekle
    if (isHoliday) {
      textColor = Colors.red.shade700;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: isToday
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : isHoliday
                ? Border.all(color: Colors.red.shade300, width: 1)
                : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${dayData.date.day}',
              style: TextStyle(
                fontWeight: (isToday || isHoliday) ? FontWeight.bold : FontWeight.normal,
                color: textColor,
                fontSize: 12,
              ),
            ),
          ),
          if (isHoliday)
            const Positioned(
              top: 2,
              right: 2,
              child: Icon(
                Icons.star,
                color: Colors.red,
                size: 8,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _legendItem(Colors.indigo.shade200, 'Gece'),
            _legendItem(Colors.amber.shade200, 'Sabah'),
            _legendItem(Colors.orange.shade200, 'Akşam'),
            _legendItem(Colors.grey.shade300, 'Tatil'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.red, size: 10),
            const SizedBox(width: 4),
            Text('Resmi Tatil / Bayram', style: TextStyle(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
