import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/leave.dart';
import '../../models/leave_type.dart';
import '../../services/database_service.dart';
import 'add_leave_screen.dart';

class LeaveCalendarScreen extends StatefulWidget {
  const LeaveCalendarScreen({super.key});

  @override
  State<LeaveCalendarScreen> createState() => _LeaveCalendarScreenState();
}

class _LeaveCalendarScreenState extends State<LeaveCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Leave> _leaves = [];

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  void _loadLeaves() {
    setState(() {
      _leaves = DatabaseService.getAllLeaves();
    });
  }

  List<Leave> _getLeavesForDay(DateTime day) {
    return _leaves.where((leave) {
      final start = DateTime(leave.startDate.year, leave.startDate.month, leave.startDate.day);
      final end = DateTime(leave.endDate.year, leave.endDate.month, leave.endDate.day);
      final check = DateTime(day.year, day.month, day.day);
      return !check.isBefore(start) && !check.isAfter(end);
    }).toList();
  }

  Color _getColorForLeaveType(LeaveType type) {
    switch (type) {
      case LeaveType.annual:
        return const Color(0xFF2196F3); // Mavi
      case LeaveType.unpaid:
        return Colors.orange;
      case LeaveType.administrative:
        return Colors.purple;
      case LeaveType.marriage:
        return Colors.pink;
      case LeaveType.bereavement:
        return Colors.grey;
      case LeaveType.ssk:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İzin Takvimi'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'tr_TR',
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getLeavesForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, leaves) {
                if (leaves.isEmpty) return null;
                
                final leaveList = leaves.cast<Leave>();
                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: leaveList.take(3).map((leave) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: _getColorForLeaveType(leave.type),
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red.shade300),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const Divider(),
          // Selected day leaves
          Expanded(
            child: _selectedDay == null
                ? _buildLegend()
                : _buildSelectedDayLeaves(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLeaveScreen(initialDate: _selectedDay),
            ),
          ).then((_) => _loadLeaves());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İzin Türleri',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: LeaveType.values.map((type) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getColorForLeaveType(type),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${type.icon} ${type.displayName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayLeaves() {
    final leaves = _getLeavesForDay(_selectedDay!);
    
    if (leaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              DateFormat('d MMMM yyyy', 'tr_TR').format(_selectedDay!),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Bu tarihte izin yok',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaves.length,
      itemBuilder: (context, index) {
        final leave = leaves[index];
        return Card(
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getColorForLeaveType(leave.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(leave.type.icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            title: Text(leave.type.displayName),
            subtitle: Text(
              '${DateFormat('d MMM', 'tr_TR').format(leave.startDate)} - '
              '${DateFormat('d MMM', 'tr_TR').format(leave.endDate)} '
              '(${leave.days.toStringAsFixed(leave.days == leave.days.toInt() ? 0 : 1)} gün)',
            ),
            trailing: leave.note != null
                ? const Icon(Icons.note, size: 16, color: Colors.grey)
                : null,
          ),
        );
      },
    );
  }
}
