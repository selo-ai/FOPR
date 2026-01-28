import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quick_actions/quick_actions.dart';
import '../services/database_service.dart';
import '../services/widget_service.dart';
import 'overtime/overtime_screen.dart';

import '../services/salary_service.dart'; // Added import
import 'overtime/add_overtime_screen.dart';
import 'leave/leave_screen.dart';
import 'leave/add_leave_screen.dart';
import 'shift/shift_screen.dart';
import 'settings/settings_screen.dart';
import 'notes/notes_screen.dart';
import 'salary/salary_screen.dart';
import 'salary/add_salary_record_screen.dart';
import '../models/salary_record.dart';
import '../widgets/shift_calendar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _monthlyTotal = 0;
  double _yearlyTotal = 0;
  double _monthlyLeave = 0;
  double _yearlyLeaveRemaining = 0;

  double _currentEarnings = 0; // New State
  bool _isCalendarVisible = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initQuickActions();
    
    // WidgetsBinding is used to show dialog after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
    });
  }

  void _initQuickActions() {
    const QuickActions quickActions = QuickActions();
    
    quickActions.initialize((shortcutType) {
      if (shortcutType == 'add_overtime') { // Updated type
        _navigateToAddOvertime();
      } else if (shortcutType == 'add_leave') {
        _navigateToAddLeave();
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'add_overtime', // Updated type
        localizedTitle: 'Mesai Ekle',
        icon: 'launcher_icon',
      ),
      const ShortcutItem(
        type: 'add_leave',
        localizedTitle: 'İzin Ekle',
        icon: 'launcher_icon',
      ),
    ]);
  }

  void _navigateToAddOvertime() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddOvertimeScreen(),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToAddLeave() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddLeaveScreen(),
      ),
    ).then((_) => _loadData());
  }

  void _checkOnboarding() {
    final settings = DatabaseService.getSettings();
    if (settings.fullName == null || settings.fullName!.isEmpty) {
      _showOnboardingDialog();
    }
  }

  void _showOnboardingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 10),
            Text('Profil Bilgisi Eksik'),
          ],
        ),
        content: const Text(
          'Uygulamayı verimli kullanabilmek için lütfen ayarlar menüsünden Ad Soyad ve diğer profil bilgilerinizi tamamlayınız.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Diyaloğu kapat
              _navigateToSettings(context); // Ayarlara git
            },
            child: const Text('Ayarlara Git'),
          ),
        ],
      ),
    );
  }

  void _loadData() {
    final now = DateTime.now();
    setState(() {
      _monthlyTotal = DatabaseService.getMonthlyTotal(now.year, now.month);
      _yearlyTotal = DatabaseService.getYearlyTotal(now.year);
      _monthlyLeave = DatabaseService.getUsedLeaveDaysByMonth(now.year, now.month);
      _yearlyLeaveRemaining = DatabaseService.getRemainingAnnualLeaveDays(now.year);
    });
    
    // Async avg calculation
    SalaryService.calculateMonthToDateEarnings(now.year, now.month, now.day).then((val) {
        setState(() {
            _currentEarnings = val;
        });
    });

    WidgetService.updateWidget(
      monthlyOvertime: _monthlyTotal,
      yearlyOvertime: _yearlyTotal,
      monthlyLeave: _monthlyLeave,
      yearlyLeave: _yearlyLeaveRemaining,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FOPR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Vardiya Takvimi Toggle Butonu
            _buildModuleCard(
              context,
              icon: Icons.calendar_month,
              title: 'Vardiya Takvimi',
              subtitle: _isCalendarVisible ? 'Gizlemek için dokunun' : 'Görüntülemek için dokunun',
              onTap: () {
                setState(() {
                  _isCalendarVisible = !_isCalendarVisible;
                });
              },
              isHighlighted: _isCalendarVisible,
            ),
            
            if (_isCalendarVisible) ...[
              const SizedBox(height: 8),
              const ShiftCalendarWidget(),
            ],
            
            const SizedBox(height: 16),

            // Header Stats
            _buildEarningsCard(), // New Card
            const SizedBox(height: 16),
            _buildStatsHeader(),
            const SizedBox(height: 32),

            // Modules
            /* Text(
              'Modüller',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16), */

            // Module Cards
            _buildModuleCard(
              context,
              icon: Icons.schedule_outlined,
              title: 'Fazla Mesai',
              subtitle: 'Mesai kayıtları ve takibi',
              onTap: () => _navigateToOvertime(context),
            ),

            // Placeholder cards for future modules
            _buildModuleCard(
              context,
              icon: Icons.beach_access_outlined,
              title: 'İzin',
              subtitle: 'İzin kayıtları ve takibi',
              onTap: () => _navigateToLeave(context),
            ),
            _buildSalaryCard(context),
            _buildModuleCard(
              context,
              icon: Icons.calendar_month_outlined,
              title: 'Vardiya Hesaplama',
              subtitle: 'Hangi gün hangi vardiya?',
              onTap: () => _navigateToShift(context),
            ),
            _buildModuleCard(
              context,
              icon: Icons.note_alt_outlined,
              title: 'Notlar',
              subtitle: 'Notlarınızı tutun',
              onTap: () => _navigateToNotes(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
            BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
            const Text(
                'GÜNCEL HAKEDİŞ (TAHMİNİ)',
                style: TextStyle(
                    color: Colors.white70, 
                    fontSize: 12, 
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                ),
            ),
            const SizedBox(height: 8),
            Text(
                NumberFormat.currency(symbol: '₺', decimalDigits: 2, locale: 'tr_TR').format(_currentEarnings),
                style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 32, 
                    fontWeight: FontWeight.bold,
                ),
            ),
             const SizedBox(height: 4),
             Text(
                '${DateFormat('d MMMM yyyy', 'tr_TR').format(DateTime.now())} itibariyle',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatColumn(
              title: 'FAZLA MESAİ',
              monthlyValue: _monthlyTotal.toStringAsFixed(1),
              yearlyValue: _yearlyTotal.toStringAsFixed(1),
              unit: 'saat',
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
          Expanded(
            child: _buildStatColumn(
              title: 'YILLIK İZİN',
              monthlyValue: _monthlyLeave.toStringAsFixed(0),
              yearlyValue: _yearlyLeaveRemaining.toStringAsFixed(0),
              unit: 'gün',
              yearlyLabel: 'Kalan',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required String title,
    required String monthlyValue,
    required String yearlyValue,
    required String unit,
    String monthlyLabel = 'Aylık',
    String yearlyLabel = 'Yıllık',
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(monthlyValue, monthlyLabel, unit),
            _buildStatItem(yearlyValue, yearlyLabel, unit),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$label ($unit)',
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: isHighlighted ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
        elevation: isHighlighted ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isHighlighted 
            ? BorderSide(color: Theme.of(context).primaryColor, width: 1)
            : BorderSide.none,
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: enabled
                        ? (isHighlighted 
                            ? Theme.of(context).primaryColor 
                            : Theme.of(context).colorScheme.primary.withOpacity(0.1))
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: enabled
                        ? (isHighlighted 
                            ? Colors.white 
                            : Theme.of(context).colorScheme.primary)
                        : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: enabled ? null : Colors.grey,
                              fontWeight: isHighlighted ? FontWeight.bold : null,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: enabled ? null : Colors.grey.shade400,
                            ),
                      ),
                    ],
                  ),
                ),
                if (enabled)
                  Icon(
                    isHighlighted ? Icons.keyboard_arrow_down : Icons.chevron_right,
                    color: isHighlighted 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToOvertime(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OvertimeScreen()),
    ).then((_) => _loadData());
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    ).then((_) => _loadData());
  }

  void _navigateToLeave(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaveScreen()),
    ).then((_) => _loadData());
  }

  void _navigateToShift(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShiftScreen()),
    );
  }

  Widget _buildSalaryCard(BuildContext context) {
    // Get latest salary record
    final records = DatabaseService.getAllSalaryRecords();
    String subtitle = 'Maaş ve kesinti takibi';
    
    if (records.isNotEmpty) {
      final latest = records.first; // Already sorted by date desc in DatabaseService
      final formatted = NumberFormat.currency(symbol: '₺', decimalDigits: 0, locale: 'tr_TR').format(latest.totalNetPay);
      final month = DateFormat('MMMM', 'tr_TR').format(DateTime(latest.year, latest.month));
      subtitle = '$month: $formatted';
    }

    return _buildModuleCard(
      context,
      icon: Icons.payments_outlined,
      title: 'Maaş Takip',
      subtitle: subtitle,
      onTap: () => _navigateToSalary(context),
    );
  }

  void _navigateToSalary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SalaryScreen()),
    );
  }

  void _navigateToNotes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotesScreen()),
    );
  }
}
