import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/overtime.dart';
import '../../services/database_service.dart';
import '../../services/export_service.dart';
import 'add_overtime_screen.dart';
import 'overtime_calendar_screen.dart';

class OvertimeScreen extends StatefulWidget {
  const OvertimeScreen({super.key});

  @override
  State<OvertimeScreen> createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends State<OvertimeScreen> {
  late PageController _pageController;
  late DateTime _currentMonth;
  final DateTime _startMonth = DateTime(2024, 1); // Başlangıç ayı
  int _initialPage = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    
    // Calculate initial page (months from start)
    _initialPage = _monthsBetween(_startMonth, _currentMonth);
    _currentPage = _initialPage;
    _pageController = PageController(initialPage: _initialPage);
    
    // Show onboarding on first visit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowOnboarding();
    });
  }

  void _checkAndShowOnboarding() {
    final settings = DatabaseService.getSettings();
    if (!settings.overtimeTutorialShown) {
      _showOnboardingDialog();
    }
  }

  void _showOnboardingDialog() {
    bool dontShowAgain = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.schedule, color: Color(0xFF2196F3)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Fazla Mesai Modülü',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTipItem(Icons.add_circle_outline, 'Mesai Ekle', 
                    'Sağ alttaki butona tıklayarak hızlıca mesai ekleyin.'),
                _buildTipItem(Icons.swipe, 'Sola Kaydır → Sil', 
                    'Mesai kaydını silmek için sola kaydırın.'),
                _buildTipItem(Icons.edit_outlined, 'Sağa Kaydır → Düzenle', 
                    'Mesai kaydını düzenlemek için sağa kaydırın.'),
                _buildTipItem(Icons.calendar_month, 'Takvim Görünümü', 
                    'Takvim ikonuyla geçmiş tarihlere mesai girebilirsiniz.'),
                _buildTipItem(Icons.swipe_left_alt, 'Aylar Arası Geçiş', 
                    'Ekranı sola/sağa kaydırarak farklı ayları görüntüleyin.'),
                _buildTipItem(Icons.bar_chart, 'Yıllık Rapor', 
                    'Grafik ikonuyla yıllık özet ve dışa aktarma yapın.'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: dontShowAgain,
                      onChanged: (value) {
                        setDialogState(() => dontShowAgain = value ?? false);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Tekrar gösterme',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (dontShowAgain) {
                  final settings = DatabaseService.getSettings();
                  settings.overtimeTutorialShown = true;
                  settings.save();
                }
                Navigator.pop(context);
              },
              child: const Text('Anladım'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    final now = DateTime.now();
    final currentMonthPage = _monthsBetween(_startMonth, DateTime(now.year, now.month));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fazla Mesai'),
        actions: [
          // "Bu Ay" butonu - sadece geçmiş aydayken göster
          if (_currentPage < currentMonthPage)
            TextButton(
              onPressed: () {
                _pageController.animateToPage(
                  currentMonthPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Bu Ay'),
            ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => _showYearlyReport(context),
            tooltip: 'Yıllık Rapor',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => _navigateToCalendar(context),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
            _currentMonth = _getMonthFromPage(page);
          });
        },
        // Limit to current month (can't go to future)
        itemCount: currentMonthPage + 1,
        itemBuilder: (context, index) {
          final month = _getMonthFromPage(index);
          return _MonthPage(
            year: month.year,
            month: month.month,
            onDataChanged: () => setState(() {}),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('Mesai Ekle'),
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddOvertimeScreen()),
    ).then((_) => setState(() {}));
  }

  void _navigateToCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OvertimeCalendarScreen()),
    ).then((_) => setState(() {}));
  }

  void _showYearlyReport(BuildContext context) {
    final year = _currentMonth.year;
    final monthNames = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    
    // Get monthly totals
    final monthlyTotals = <int, double>{};
    double yearlyTotal = 0;
    for (int m = 1; m <= 12; m++) {
      final total = DatabaseService.getMonthlyTotal(year, m);
      monthlyTotals[m] = total;
      yearlyTotal += total;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$year Yılı Raporu',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          'Aylık mesai dağılımı',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Monthly list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final total = monthlyTotals[month] ?? 0;
                  final isCurrentMonth = DateTime.now().year == year && 
                                         DateTime.now().month == month;
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isCurrentMonth
                          ? const Color(0xFF2196F3).withOpacity(0.1)
                          : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrentMonth
                          ? Border.all(color: const Color(0xFF2196F3).withOpacity(0.3))
                          : null,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            monthNames[index],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: isCurrentMonth ? FontWeight.w600 : FontWeight.w500,
                                  color: isCurrentMonth ? const Color(0xFF2196F3) : null,
                                ),
                          ),
                        ),
                        Expanded(
                          child: total > 0
                              ? Container(
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: yearlyTotal > 0 ? total / yearlyTotal : 0,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isCurrentMonth
                                            ? const Color(0xFF2196F3)
                                            : Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                        ),
                        Text(
                          total > 0 ? '${total.toStringAsFixed(1)} saat' : '-',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: total > 0 ? FontWeight.w600 : FontWeight.w400,
                                color: total > 0 ? null : Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Total footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Yıllık Toplam',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '${yearlyTotal.toStringAsFixed(1)} saat',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2196F3),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Export buttons
                  Builder(
                    builder: (buttonContext) {
                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final scaffoldMessenger = ScaffoldMessenger.of(buttonContext);
                                Navigator.pop(buttonContext);
                                try {
                                  final path = await ExportService.exportToPDF(year);
                                  if (path != null) {
                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('PDF kaydedildi'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(content: Text('PDF hatası: $e')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.save_alt, size: 18),
                              label: const Text('PDF Kaydet'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final scaffoldMessenger = ScaffoldMessenger.of(buttonContext);
                                Navigator.pop(buttonContext);
                                try {
                                  await ExportService.shareTextSummary(year);
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(content: Text('Paylaşım hatası: $e')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Paylaş'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single month page widget
class _MonthPage extends StatelessWidget {
  final int year;
  final int month;
  final VoidCallback onDataChanged;

  const _MonthPage({
    required this.year,
    required this.month,
    required this.onDataChanged,
  });

  Color _getQuotaColor(double current, double quota, BuildContext context) {
    if (quota <= 0) return Theme.of(context).textTheme.displayLarge?.color ?? Colors.black;
    final percentage = current / quota;
    if (percentage >= 1.0) return const Color(0xFFB71C1C); // Dark red when exceeded
    if (percentage >= 0.7) return Colors.red;
    if (percentage >= 0.5) return Colors.orange;
    return Theme.of(context).textTheme.displayLarge?.color ?? Colors.black;
  }

  bool _isQuotaExceeded(double current, double quota) {
    return quota > 0 && current > quota;
  }

  FontWeight _getQuotaFontWeight(double current, double quota) {
    if (quota > 0 && current >= quota) return FontWeight.w700;
    return FontWeight.w300;
  }

  @override
  Widget build(BuildContext context) {
    final overtimes = DatabaseService.getOvertimesByMonth(year, month);
    final monthlyTotal = DatabaseService.getMonthlyTotal(year, month);
    final yearlyTotal = DatabaseService.getYearlyTotal(year);
    final settings = DatabaseService.getSettings();
    final monthlyQuota = settings.monthlyQuota;
    final yearlyQuota = settings.yearlyQuota;
    final monthDate = DateTime(year, month);
    final monthName = DateFormat('MMMM yyyy', 'tr_TR').format(monthDate);
    final isCurrentMonth = DateTime.now().year == year && DateTime.now().month == month;

    // Format display strings
    final monthlyDisplay = monthlyQuota > 0
        ? '${monthlyTotal.toStringAsFixed(1)} / ${monthlyQuota.toStringAsFixed(1)}'
        : monthlyTotal.toStringAsFixed(1);
    final yearlyDisplay = yearlyQuota > 0
        ? '${yearlyTotal.toStringAsFixed(1)} / ${yearlyQuota.toStringAsFixed(1)}'
        : yearlyTotal.toStringAsFixed(1);

    return Column(
      children: [
        // Stats header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                '$monthlyDisplay saat',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 32, // Reduced by 1/3 from 48
                      color: _getQuotaColor(monthlyTotal, monthlyQuota, context),
                      fontWeight: _getQuotaFontWeight(monthlyTotal, monthlyQuota),
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isCurrentMonth)
                    Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.5),
                    ),
                  Text(
                    monthName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2196F3), // Vibrant blue
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isCurrentMonth
                        ? Colors.transparent
                        : Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.5),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '← Kaydır →',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).textTheme.labelMedium?.color?.withOpacity(0.4),
                      fontSize: 10,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$year Yılı: $yearlyDisplay saat',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),

        // List header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCurrentMonth ? 'Bu Ayki Kayıtlar' : 'Kayıtlar',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${overtimes.length} kayıt',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // List
        Expanded(
          child: overtimes.isEmpty
              ? _buildEmptyState(context, isCurrentMonth)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: overtimes.length,
                  itemBuilder: (context, index) {
                    return _OvertimeItem(
                      overtime: overtimes[index],
                      onDeleted: onDataChanged,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isCurrentMonth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isCurrentMonth ? 'Henüz mesai kaydı yok' : 'Bu ayda kayıt yok',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (isCurrentMonth) ...[
            const SizedBox(height: 8),
            Text(
              'Yeni mesai eklemek için butona tıklayın',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// Single overtime item widget
class _OvertimeItem extends StatelessWidget {
  final Overtime overtime;
  final VoidCallback onDeleted;

  const _OvertimeItem({
    required this.overtime,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM, EEEE', 'tr_TR').format(overtime.date);

    return Dismissible(
      key: Key(overtime.id),
      direction: DismissDirection.horizontal,
      // Edit background (swipe right)
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
      // Delete background (swipe left)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
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
        } else {
          // Edit - show edit dialog
          await _showEditDialog(context);
          return false; // Don't dismiss, just refresh
        }
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await DatabaseService.deleteOvertime(overtime.id);
          onDeleted();
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${overtime.hours}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (overtime.note != null && overtime.note!.isNotEmpty)
                      Text(
                        overtime.note!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Text(
                'saat',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final hoursController = TextEditingController(text: overtime.hours.toString());
    final noteController = TextEditingController(text: overtime.note ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_outlined, color: Color(0xFF2196F3), size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Mesai Düzenle'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hoursController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Saat',
                suffixText: 'saat',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Not (Opsiyonel)',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newHours = double.tryParse(hoursController.text.replaceAll(',', '.'));
              if (newHours != null && newHours > 0) {
                overtime.hours = newHours;
                overtime.note = noteController.text.isNotEmpty ? noteController.text : null;
                await overtime.save();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    onDeleted(); // Refresh the list
  }
}
