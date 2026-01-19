import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import 'overtime/overtime_screen.dart';
import 'leave/leave_screen.dart';
import 'shift/shift_screen.dart';
import 'settings/settings_screen.dart';
import 'notes/notes_screen.dart';
import 'salary/salary_screen.dart';
import '../models/salary_record.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _monthlyTotal = 0;
  double _yearlyTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final now = DateTime.now();
    setState(() {
      _monthlyTotal = DatabaseService.getMonthlyTotal(now.year, now.month);
      _yearlyTotal = DatabaseService.getYearlyTotal(now.year);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM', 'tr_TR').format(now);

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
            // Header Stats
            _buildStatsHeader(monthName),
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
              title: 'Yıllık İzin',
              subtitle: '${DatabaseService.getRemainingAnnualLeaveDays(DateTime.now().year).toStringAsFixed(0)} gün kaldı',
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

  Widget _buildStatsHeader(String monthName) {
    return Column(
      children: [
        // Monthly total - big and prominent
        Text(
          '${_monthlyTotal.toStringAsFixed(1)} saat',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 4),
        Text(
          '$monthName mesaisi',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        // Yearly total - smaller
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Yıllık: ${_yearlyTotal.toStringAsFixed(1)} saat',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
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
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: enabled
                        ? Theme.of(context).colorScheme.primary
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
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
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
      MaterialPageRoute(builder: (context) => const OvertimeScreen()),
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
