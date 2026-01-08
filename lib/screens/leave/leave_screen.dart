import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/leave.dart';
import '../../models/leave_type.dart';
import '../../services/database_service.dart';
import '../../services/export_service.dart';
import 'add_leave_screen.dart';
import 'leave_calendar_screen.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  late PageController _pageController;
  late DateTime _currentMonth;
  final DateTime _startMonth = DateTime(2024, 1);
  int _initialPage = 0;
  int _currentPage = 0;
  LeaveType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    
    _initialPage = _monthsBetween(_startMonth, _currentMonth);
    _currentPage = _initialPage;
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }

  DateTime _getMonthFromPage(int page) {
    return DateTime(_startMonth.year, _startMonth.month + page);
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = _getMonthFromPage(_currentPage);
    final monthName = DateFormat('MMMM yyyy', 'tr_TR').format(currentMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yıllık İzin'),
        actions: [
          // Yıllık özet butonu
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: () => _showYearlySummary(context, currentMonth.year),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => _navigateToCalendar(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats header
          _buildStatsHeader(currentMonth.year),
          
          // Month navigation header
          _buildMonthHeader(monthName),
          
          // Leave type filter chips
          _buildLeaveTypeFilter(currentMonth.year),
          
          // Monthly leave pages
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                final month = _getMonthFromPage(index);
                return _MonthPage(
                  year: month.year,
                  month: month.month,
                  filterType: _selectedFilter,
                  onRefresh: () => setState(() {}),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('İzin Ekle'),
      ),
    );
  }

  Widget _buildStatsHeader(int year) {
    final entitlement = DatabaseService.calculateAnnualEntitlement();
    final used = DatabaseService.getUsedAnnualLeaveDays(year);
    final remaining = DatabaseService.getRemainingAnnualLeaveDays(year);
    final isOverused = remaining < 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Hak Ediş', '$entitlement', Colors.grey),
          Container(width: 1, height: 30, color: Colors.grey.shade200),
          _buildStatItem(
            'Kullanılan',
            used.toStringAsFixed(used == used.toInt() ? 0 : 1),
            Colors.orange,
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade200),
          _buildStatItem(
            'Kalan',
            remaining.toStringAsFixed(remaining == remaining.toInt() ? 0 : 1),
            isOverused ? Colors.red : const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthHeader(String monthName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          GestureDetector(
            onTap: () => _goToCurrentMonth(),
            child: Text(
              monthName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  void _goToCurrentMonth() {
    final now = DateTime.now();
    final targetPage = _monthsBetween(_startMonth, DateTime(now.year, now.month));
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildLeaveTypeFilter(int year) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // "Tümü" butonu
          GestureDetector(
            onTap: () => setState(() => _selectedFilter = null),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedFilter == null
                    ? const Color(0xFF2196F3).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedFilter == null
                      ? const Color(0xFF2196F3)
                      : Colors.grey.shade300,
                  width: _selectedFilter == null ? 2 : 1,
                ),
              ),
              child: Text(
                'Tümü',
                style: TextStyle(
                  fontWeight: _selectedFilter == null ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                  color: _selectedFilter == null ? const Color(0xFF2196F3) : null,
                ),
              ),
            ),
          ),
          // İzin türü butonları
          ...LeaveType.values.map((type) {
            final days = DatabaseService.getTotalDaysByType(type, year);
            if (days == 0) return const SizedBox.shrink();
            
            final isSelected = _selectedFilter == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = isSelected ? null : type),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2196F3).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2196F3)
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(type.icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      '${days.toStringAsFixed(days == days.toInt() ? 0 : 1)}',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 12,
                        color: isSelected ? const Color(0xFF2196F3) : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showYearlySummary(BuildContext context, int year) {
    final entitlement = DatabaseService.calculateAnnualEntitlement();
    final used = DatabaseService.getUsedAnnualLeaveDays(year);
    final remaining = DatabaseService.getRemainingAnnualLeaveDays(year);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$year Yılı İzin Özeti',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              
              // Summary cards
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Hak Ediş', entitlement.toString(), Colors.grey)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard('Kullanılan', used.toStringAsFixed(0), Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard('Kalan', remaining.toStringAsFixed(0), 
                    remaining < 0 ? Colors.red : const Color(0xFF2196F3))),
                ],
              ),
              const SizedBox(height: 24),
              
              // Leave type breakdown
              Text(
                'İzin Türü Dağılımı',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...LeaveType.values.map((type) {
                final days = DatabaseService.getTotalDaysByType(type, year);
                if (days == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(type.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(type.displayName)),
                      Text(
                        '${days.toStringAsFixed(days == days.toInt() ? 0 : 1)} gün',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }),

              // Export buttons
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ExportService.exportLeaveToPDF(year);
                      },
                      icon: const Icon(Icons.save_alt),
                      label: const Text('PDF Kaydet'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ExportService.shareLeaveSummary(year);
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Paylaş'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddLeaveScreen()),
    ).then((_) => setState(() {}));
  }

  void _navigateToCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaveCalendarScreen()),
    ).then((_) => setState(() {}));
  }
}

/// Monthly leave page
class _MonthPage extends StatelessWidget {
  final int year;
  final int month;
  final LeaveType? filterType;
  final VoidCallback onRefresh;

  const _MonthPage({
    required this.year,
    required this.month,
    required this.filterType,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Get leaves for this month
    var leaves = DatabaseService.getAllLeaves().where((l) {
      return l.startDate.year == year && l.startDate.month == month;
    }).toList();
    
    // Apply type filter
    if (filterType != null) {
      leaves = leaves.where((l) => l.type == filterType).toList();
    }
    
    leaves.sort((a, b) => a.startDate.compareTo(b.startDate));

    if (leaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.beach_access_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Bu ayda izin kaydı yok',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: leaves.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _LeaveItem(
            leave: leaves[index],
            onDeleted: onRefresh,
          ),
        );
      },
    );
  }
}

/// Single leave item widget
class _LeaveItem extends StatelessWidget {
  final Leave leave;
  final VoidCallback onDeleted;

  const _LeaveItem({
    required this.leave,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final startStr = DateFormat('d MMM', 'tr_TR').format(leave.startDate);
    final endStr = DateFormat('d MMM', 'tr_TR').format(leave.endDate);
    final isSingleDay = leave.startDate == leave.endDate;
    final dateStr = isSingleDay ? startStr : '$startStr - $endStr';

    return Dismissible(
      key: Key(leave.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('İzni Sil'),
              content: const Text('Bu izin kaydını silmek istediğinize emin misiniz?'),
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
        } else {
          // Edit
          _showEditDialog(context);
          return false;
        }
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await DatabaseService.deleteLeave(leave.id);
          onDeleted();
        }
      },
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    leave.type.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.type.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (leave.note != null && leave.note!.isNotEmpty)
                      Text(
                        leave.note!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${leave.days.toStringAsFixed(leave.days == leave.days.toInt() ? 0 : 1)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2196F3),
                        ),
                  ),
                  Text(
                    'gün',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    DateTime startDate = leave.startDate;
    DateTime endDate = leave.endDate;
    final noteController = TextEditingController(text: leave.note ?? '');
    double calculatedDays = leave.days;

    void recalculateDays() {
      if (leave.type.isHourBased) {
        calculatedDays = leave.hours! / 8.0;
      } else if (leave.type.fixedDays != null) {
        calculatedDays = leave.type.fixedDays!.toDouble();
      } else {
        calculatedDays = Leave.calculateDays(startDate, endDate, leave.type.includesWeekends);
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Text(leave.type.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              const Text('İzni Düzenle'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leave.type.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 16),
                
                // Start date
                if (!leave.type.isHourBased) ...[
                  Text('Başlangıç', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        locale: const Locale('tr', 'TR'),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          startDate = picked;
                          if (endDate.isBefore(startDate)) {
                            endDate = startDate;
                          }
                          recalculateDays();
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(startDate),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // End date (only if not fixed days)
                  if (leave.type.fixedDays == null) ...[
                    Text('Bitiş', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: startDate,
                          lastDate: DateTime(2030),
                          locale: const Locale('tr', 'TR'),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            endDate = picked;
                            recalculateDays();
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(endDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
                
                // Days display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_available, color: Color(0xFF2196F3), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${calculatedDays.toStringAsFixed(calculatedDays == calculatedDays.toInt() ? 0 : 1)} gün',
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Note
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Not',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                leave.startDate = startDate;
                leave.endDate = endDate;
                leave.days = calculatedDays;
                leave.note = noteController.text.isNotEmpty ? noteController.text : null;
                await leave.save();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                onDeleted(); // Refresh
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}

