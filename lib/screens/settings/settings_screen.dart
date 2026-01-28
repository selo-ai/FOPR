import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../models/settings.dart';
import '../../models/shift_type.dart';

import '../../services/database_service.dart';
import '../salary/salary_settings_screen.dart'; // Added import

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Settings _settings;
  final _nameController = TextEditingController();
  // removed _hourlyRateController
  final _monthlyQuotaController = TextEditingController();
  final _yearlyQuotaController = TextEditingController();
  DateTime? _startDate;
  DateTime? _shiftStartDate;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settings = DatabaseService.getSettings();
    
    // Migration Logic: Check if hourlyRate exists in Settings but not in SalarySettings
    if (_settings.hourlyRate > 0) {
        final salarySettings = await DatabaseService.getSalarySettings();
        if (salarySettings.hourlyGrossRate == 0) {
            salarySettings.hourlyGrossRate = _settings.hourlyRate;
            await salarySettings.save();
            // Optional: reset _settings.hourlyRate or keep as backup
        }
    }

    _nameController.text = _settings.fullName ?? '';
    // _hourlyRateController removed
    _monthlyQuotaController.text =
        _settings.monthlyQuota > 0 ? _settings.monthlyQuota.toString() : '';
    _yearlyQuotaController.text =
        _settings.yearlyQuota > 0 ? _settings.yearlyQuota.toString() : '';
    _startDate = _settings.startDate;
    _shiftStartDate = _settings.shiftStartDate;
    setState(() {}); // Refresh UI after async
  }

  @override
  void dispose() {
    _nameController.dispose();
    // _hourlyRateController removed
    _monthlyQuotaController.dispose();
    _yearlyQuotaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Theme section
          _buildSectionHeader('Tema'),
          _buildThemeSelector(),
          const SizedBox(height: 32),

          // Personal info section
          _buildSectionHeader('Kişisel Bilgiler'),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _nameController,
            label: 'Adı Soyadı',
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 12),
          _buildDateField(),
          const SizedBox(height: 32),

          // Overtime settings section
          _buildSectionHeader('Mesai & Maaş Ayarları'),
          const SizedBox(height: 12),
          
          // Navigation to Salary Settings
          Card(
            child: ListTile(
                leading: const Icon(Icons.calculate_outlined, color: Colors.blue),
                title: const Text('Maaş Parametreleri'),
                subtitle: const Text('Saatlik ücret, kesintiler ve aile yardımı'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                    Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const SalarySettingsScreen())
                    ).then((_) => _loadSettings());
                },
            ),
          ),
          const SizedBox(height: 12),

          /* _buildTextField(
            controller: _hourlyRateController,
            label: 'Saat Ücreti (₺)',
            icon: Icons.payments_outlined,
            keyboardType: TextInputType.number,
          ), 
          removed */


          const SizedBox(height: 12),
          _buildTextField(
            controller: _monthlyQuotaController,
            label: 'Aylık Mesai Kotası (saat)',
            icon: Icons.calendar_view_month_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _yearlyQuotaController,
            label: 'Yıllık Mesai Kotası (saat)',
            icon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),

          // Shift settings section
          _buildSectionHeader('Vardiya Ayarları'),
          const SizedBox(height: 12),
          _buildShiftTypeSelector(),
          const SizedBox(height: 12),
          _buildShiftStartDateField(),
          const SizedBox(height: 40),

          // Save button
          ElevatedButton(
            onPressed: _save,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Kaydet'),
            ),
          ),
          const SizedBox(height: 20),

          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'v1.0.3',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selahattin Gültekin',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildThemeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _buildThemeOption(
              icon: Icons.brightness_auto_outlined,
              label: 'Sistem',
              mode: ThemeMode.system,
            ),
            _buildThemeOption(
              icon: Icons.light_mode_outlined,
              label: 'Açık',
              mode: ThemeMode.light,
            ),
            _buildThemeOption(
              icon: Icons.dark_mode_outlined,
              label: 'Koyu',
              mode: ThemeMode.dark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required ThemeMode mode,
  }) {
    final isSelected = _settings.themeMode == mode;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _settings.setThemeMode(mode);
          });
          // Update app theme immediately
          FOPRApp.instance?.updateTheme(mode);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildDateField() {
    final dateStr = _startDate != null
        ? DateFormat('d MMMM yyyy', 'tr_TR').format(_startDate!)
        : 'Seçilmedi';

    return Card(
      child: InkWell(
        onTap: _selectStartDate,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.work_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İşe Başlangıç Tarihi',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
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

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _save() async {
    _settings.fullName =
        _nameController.text.isNotEmpty ? _nameController.text : null;
    _settings.startDate = _startDate;
    // _hourlyRate is not updated here anymore
    _settings.monthlyQuota =
        double.tryParse(_monthlyQuotaController.text.replaceAll(',', '.')) ?? 0;
    _settings.yearlyQuota =
        double.tryParse(_yearlyQuotaController.text.replaceAll(',', '.')) ?? 0;
    _settings.shiftStartDate = _shiftStartDate;

    await DatabaseService.saveSettings(_settings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ayarlar kaydedildi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildShiftTypeSelector() {
    final shiftTypes = [
      (ShiftType.night, 'Gece', Icons.nights_stay, Colors.indigo),
      (ShiftType.morning, 'Sabah', Icons.wb_sunny, Colors.amber),
      (ShiftType.evening, 'Akşam', Icons.wb_twilight, Colors.orange),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: shiftTypes.map((item) {
            final (type, label, icon, color) = item;
            final isSelected = _settings.currentShiftTypeIndex == type.cycleIndex;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _settings.currentShiftTypeIndex = type.cycleIndex;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: color, width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(icon, color: isSelected ? color : Colors.grey),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? color : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildShiftStartDateField() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_month),
        title: const Text('Vardiya Başlangıç Tarihi'),
        subtitle: Text(
          _shiftStartDate != null
              ? DateFormat('dd MMMM yyyy', 'tr_TR').format(_shiftStartDate!)
              : 'Bugün (varsayılan)',
        ),
        trailing: const Icon(Icons.edit),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _shiftStartDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            locale: const Locale('tr', 'TR'),
          );
          if (picked != null) {
            setState(() {
              _shiftStartDate = picked;
            });
          }
        },
      ),
    );
  }
}
