import 'package:flutter/material.dart';
import '../../models/salary_settings.dart';
import '../../services/database_service.dart';

class SalarySettingsScreen extends StatefulWidget {
  const SalarySettingsScreen({super.key});

  @override
  State<SalarySettingsScreen> createState() => _SalarySettingsScreenState();
}

class _SalarySettingsScreenState extends State<SalarySettingsScreen> {
  late SalarySettings _settings;
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _hourlyRateController;
  late TextEditingController _weeklyHoursController;
  late TextEditingController _childCountController;
  late TextEditingController _childAllowanceController;
  late TextEditingController _unionRateController;
  late TextEditingController _besAmountController;
  late TextEditingController _fuelAllowanceController;
  late TextEditingController _healthInsuranceController;
  late TextEditingController _educationFundController;
  late TextEditingController _foundationDeductionController;
  late TextEditingController _ossPersonCountController;
  late TextEditingController _ossCostPerPersonController;
  late TextEditingController _executionAmountController;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settings = await DatabaseService.getSalarySettings();
    
    _hourlyRateController = TextEditingController(text: _settings.hourlyGrossRate.toString());
    _weeklyHoursController = TextEditingController(text: _settings.weeklyWorkHours.toString());
    _childCountController = TextEditingController(text: _settings.childCount.toString());
    _childAllowanceController = TextEditingController(text: _settings.childAllowancePerChild.toString());
    _unionRateController = TextEditingController(text: _settings.unionRate.toString());
    _besAmountController = TextEditingController(text: _settings.besAmount.toString());
    _fuelAllowanceController = TextEditingController(text: _settings.fuelAllowance.toString());
    _healthInsuranceController = TextEditingController(text: _settings.healthInsurance.toString());
    _educationFundController = TextEditingController(text: _settings.educationFund.toString());
    _foundationDeductionController = TextEditingController(text: _settings.foundationDeduction.toString());
    
    // Initialize OSS controllers safely
    _ossPersonCountController = TextEditingController(text: _settings.ossPersonCount.toString());
    _ossCostPerPersonController = TextEditingController(text: _settings.ossCostPerPerson.toString());
    _executionAmountController = TextEditingController(text: _settings.executionAmount.toString());

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    _settings.hourlyGrossRate = double.tryParse(_hourlyRateController.text) ?? 0.0;
    _settings.weeklyWorkHours = double.tryParse(_weeklyHoursController.text) ?? 37.5;
    _settings.childCount = int.tryParse(_childCountController.text) ?? 0;
    _settings.childAllowancePerChild = double.tryParse(_childAllowanceController.text) ?? 0.0;
    _settings.unionRate = double.tryParse(_unionRateController.text) ?? 0.0;
    _settings.besAmount = double.tryParse(_besAmountController.text) ?? 0.0;
    _settings.fuelAllowance = double.tryParse(_fuelAllowanceController.text) ?? 0.0;
    _settings.healthInsurance = double.tryParse(_healthInsuranceController.text) ?? 0.0;
    _settings.educationFund = double.tryParse(_educationFundController.text) ?? 0.0;
    _settings.foundationDeduction = double.tryParse(_foundationDeductionController.text) ?? 0.0;
    _settings.ossPersonCount = int.tryParse(_ossPersonCountController.text) ?? 0;
    _settings.ossCostPerPerson = double.tryParse(_ossCostPerPersonController.text) ?? 0.0;
    _settings.executionAmount = double.tryParse(_executionAmountController.text) ?? 0.0;

    await _settings.save();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ayarlar kaydedildi')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _hourlyRateController.dispose();
    _weeklyHoursController.dispose();
    _childCountController.dispose();
    _childAllowanceController.dispose();
    _unionRateController.dispose();
    _besAmountController.dispose();
    _fuelAllowanceController.dispose();
    _healthInsuranceController.dispose();
    _educationFundController.dispose();
    _foundationDeductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maaş Ayarları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSettings,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Temel Bilgiler'),
            _buildNumberField('Saatlik Brüt Ücret (TL)', _hourlyRateController),
            _buildNumberField('Haftalık Çalışma Saati', _weeklyHoursController),
            
            _buildSectionHeader('Aile Yardımı'),
            Row(
              children: [
                Expanded(child: _buildNumberField('Çocuk Sayısı', _childCountController, isInt: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildNumberField('Çocuk Başı (TL)', _childAllowanceController)),
              ],
            ),
            _buildNumberField('Yakacak Yardımı (TL)', _fuelAllowanceController),

            _buildSectionHeader('Kesintiler & Özel Sigortalar'),
            _buildSwitch('Sendika Üyeliği (1 Günlük Yevmiye)', _settings.hasUnion, (val) => setState(() => _settings.hasUnion = val)),

            _buildSwitch('Vakıf BES (Brüt %6)', _settings.hasBES, (val) => setState(() => _settings.hasBES = val)),

            _buildSwitch('Sağlık Sigortası (ÖSS - TSS)', _settings.hasHealthInsurance, (val) => setState(() => _settings.hasHealthInsurance = val)),
            if (_settings.hasHealthInsurance)
              Row(
                children: [
                  Expanded(child: _buildNumberField('Kişi Sayısı', _ossPersonCountController, isInt: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildNumberField('Kişi Başı (TL)', _ossCostPerPersonController)),
                ],
              ),

            _buildSwitch('İcra / Nafaka Kesintisi', _settings.hasExecution, (val) => setState(() => _settings.hasExecution = val)),
            if (_settings.hasExecution)
              _buildNumberField('Kesinti Tutarı (TL)', _executionAmountController),

            _buildSectionHeader('Diğer Kesintiler'),
            _buildNumberField('Öğrenim Fonu (TL)', _educationFundController),
            _buildNumberField('Vakıf Kesintisi (TL)', _foundationDeductionController),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('KAYDET'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller, {bool isInt = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            if (controller.text.isEmpty) {
              controller.text = isInt ? '0' : '0.0';
            }
          } else {
             if (controller.text == '0.0' || controller.text == '0') {
               controller.text = '';
             }
          }
        },
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          // onTap ve eski mantık yerine Focus widget'ı kullanıyoruz
        ),
      ),
    );
  }
  Widget _buildSwitch(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          Transform.scale(
            scale: 0.8, // %80 boyuta küçült
            child: Switch(
              value: value, 
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
