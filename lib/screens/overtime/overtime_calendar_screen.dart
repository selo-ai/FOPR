import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/overtime.dart';
import '../../services/database_service.dart';
import 'add_overtime_screen.dart';

class OvertimeCalendarScreen extends StatefulWidget {
  const OvertimeCalendarScreen({super.key});

  @override
  State<OvertimeCalendarScreen> createState() => _OvertimeCalendarScreenState();
}

class _OvertimeCalendarScreenState extends State<OvertimeCalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, List<Overtime>> _overtimeMap = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadData();
  }

  void _loadData() {
    final overtimes = DatabaseService.getAllOvertimes();
    final Map<DateTime, List<Overtime>> map = {};

    for (final overtime in overtimes) {
      final date = DateTime(overtime.date.year, overtime.date.month, overtime.date.day);
      if (map[date] == null) {
        map[date] = [];
      }
      map[date]!.add(overtime);
    }

    setState(() {
      _overtimeMap = map;
    });
  }

  List<Overtime> _getOvertimesForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _overtimeMap[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
      ),
      body: Column(
        children: [
          TableCalendar<Overtime>(
            locale: 'tr_TR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getOvertimesForDay,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
              markerSize: 6,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: Theme.of(context).textTheme.titleMedium!,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 16),

          // Selected day details
          Expanded(
            child: _buildSelectedDayDetails(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOvertimeForSelectedDay(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSelectedDayDetails() {
    if (_selectedDay == null) {
      return const SizedBox.shrink();
    }

    final overtimes = _getOvertimesForDay(_selectedDay!);
    final dateStr = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(_selectedDay!);
    final totalHours = overtimes.fold(0.0, (sum, o) => sum + o.hours);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (overtimes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${totalHours.toStringAsFixed(1)} saat',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: overtimes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bu gün için kayıt yok',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: overtimes.length,
                    itemBuilder: (context, index) {
                      final overtime = overtimes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${overtime.hours}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          title: Text('${overtime.hours} saat'),
                          subtitle: overtime.note != null
                              ? Text(overtime.note!, maxLines: 1, overflow: TextOverflow.ellipsis)
                              : null,
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.grey.shade400),
                            onPressed: () => _deleteOvertime(overtime),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addOvertimeForSelectedDay() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOvertimeScreen(initialDate: _selectedDay),
      ),
    );
    _loadData();
  }

  Future<void> _deleteOvertime(Overtime overtime) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydı Sil'),
        content: const Text('Bu mesai kaydını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sil', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.deleteOvertime(overtime.id);
      _loadData();
    }
  }
}
