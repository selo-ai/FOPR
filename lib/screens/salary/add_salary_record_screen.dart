import 'package:flutter/material.dart';
import '../../models/salary_record.dart';
import '../../models/salary_settings.dart';
import '../../services/database_service.dart';
import '../../services/salary_service.dart';
import '../../services/shift_calendar_service.dart';
import '../../services/social_service.dart';
import 'package:intl/intl.dart';

class AddSalaryRecordScreen extends StatefulWidget {
  final SalaryRecord? record;

  const AddSalaryRecordScreen({super.key, this.record});

  @override
  State<AddSalaryRecordScreen> createState() => _AddSalaryRecordScreenState();
}

class _AddSalaryRecordScreenState extends State<AddSalaryRecordScreen> {
  late DateTime _selectedDate;
  late TextEditingController _normalHoursController;
  late TextEditingController _overtimeHoursController; // Auto-filled but editable
  late TextEditingController _nightShiftHoursController;
  late TextEditingController _weekendHoursController;
  late TextEditingController _publicHolidayController;
  late TextEditingController _annualLeaveController;
  late TextEditingController _advanceController;
  late TextEditingController _otosanController;
  late TextEditingController _holidayAllowanceController;
  late TextEditingController _leaveAllowanceController;
  late TextEditingController _tahsilAllowanceController;
  late TextEditingController _shoeAllowanceController;
  late TextEditingController _jobIndemnityController;
  late TextEditingController _tisAdvanceController;

  bool _isLoading = true;
  bool _hasOtosan = false;
  bool _hasHolidayAllowance = false;
  bool _hasLeaveAllowance = false;
  bool _hasTahsilAllowance = false;
  bool _hasShoeAllowance = false;
  bool _hasJobIndemnity = false;
  bool _hasTisAdvance = false;
  
  int _countAna = 0;
  int _countIlk = 0;
  int _countOrta = 0;
  int _countLise = 0;
  int _countUni = 0;

  SalarySettings? _settings;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    if (widget.record != null) {
      _selectedDate = DateTime(widget.record!.year, widget.record!.month);
    }
    
    _normalHoursController = TextEditingController();
    _overtimeHoursController = TextEditingController();
    _nightShiftHoursController = TextEditingController();
    _weekendHoursController = TextEditingController();
    _publicHolidayController = TextEditingController();
    _annualLeaveController = TextEditingController();
    _advanceController = TextEditingController();
    _otosanController = TextEditingController();
    _holidayAllowanceController = TextEditingController();
    _leaveAllowanceController = TextEditingController();
    _tahsilAllowanceController = TextEditingController();
    _shoeAllowanceController = TextEditingController();
    _jobIndemnityController = TextEditingController();
    _tisAdvanceController = TextEditingController();

    _loadData();
  }

  Future<void> _loadData() async {
    _settings = await DatabaseService.getSalarySettings();
    
    if (widget.record != null) {
      final r = widget.record!;
      _normalHoursController.text = r.normalHours.toString();
      _overtimeHoursController.text = r.overtimeHours.toString();
      _nightShiftHoursController.text = r.nightShiftHours.toString();
      _weekendHoursController.text = r.weekendHours.toString();
      _publicHolidayController.text = r.publicHolidayHours.toString(); // NEW
      _annualLeaveController.text = r.annualLeaveDays.toString(); // NEW
      _advanceController.text = r.advanceAmount.toString();
      _otosanController.text = r.otosanAllowance.toString();
      _hasOtosan = r.otosanAllowance > 0;
      
      _holidayAllowanceController.text = r.holidayAllowance.toString();
      _hasHolidayAllowance = r.holidayAllowance > 0;
      
      _leaveAllowanceController.text = r.leaveAllowance.toString();
      _hasLeaveAllowance = r.leaveAllowance > 0;
      
      _tahsilAllowanceController.text = r.tahsilAllowance.toString();
      _hasTahsilAllowance = r.tahsilAllowance > 0;
      
      _shoeAllowanceController.text = r.shoeAllowance.toString();
      _hasShoeAllowance = r.shoeAllowance > 0;
      
      _jobIndemnityController.text = r.jobIndemnity.toString();
      _hasJobIndemnity = r.jobIndemnity > 0;
      
      _tisAdvanceController.text = r.tisAdvance.toString();
      _hasTisAdvance = r.tisAdvance > 0;
    } else {
      // Default values for new record
      _normalHoursController.text = '187.5'; // 30 days default
      await _fetchAutoOvertime(_selectedDate.year, _selectedDate.month);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchAutoOvertime(int year, int month) async {
    // Mesai modülünden o ayın toplam mesaisini çek
    final monthlyOvertime = DatabaseService.getMonthlyTotal(year, month);
    _overtimeHoursController.text = monthlyOvertime.toString();
    
    // Hafta Tatili (Pazar) Hesabı
    final totalSundays = ShiftCalendarService.countSundaysInMonth(year, month);
    final totalSundayHours = totalSundays * 7.5;
    
    // Pazar günü yapılan mesaileri bul
    final sundayOvertimeHours = DatabaseService.getSundayOvertimeTotal(year, month);
    
    // Çalışılmayan (Dinlenilen) Pazar saatleri = Toplam Pazar - Çalışılan Pazar
    // Negatif çıkmaması için kontrol (gerçi mantıken çıkmaz ama tedbir)
    double restSundayHours = totalSundayHours - sundayOvertimeHours;
    if (restSundayHours < 0) restSundayHours = 0;

    _weekendHoursController.text = restSundayHours.toString();

    // Genel Tatil (Resmi/Dini) Hesabı (Pazar Hariç)
    final totalHolidayHours = ShiftCalendarService.getPublicHolidayHoursInMonth(year, month);
    final workedHolidayHours = DatabaseService.getPublicHolidayOvertimeTotal(year, month);
    
    double restHolidayHours = totalHolidayHours - workedHolidayHours;
    if (restHolidayHours < 0) restHolidayHours = 0;
    
    _publicHolidayController.text = restHolidayHours.toString();

    // Yıllık İzin Hesabı
    final annualLeaveDays = DatabaseService.getAnnualLeaveDaysInMonth(year, month);
    _annualLeaveController.text = annualLeaveDays.toString();

    // Vardiya takviminden gece vardiyası sayısını çek
    final nightShiftDays = ShiftCalendarService.countNightShiftsInMonth(year, month);
    final nightShiftHours = nightShiftDays * 7.5; // Günde 7.5 saat
    _nightShiftHoursController.text = nightShiftHours.toString();
  }

  Future<void> _selectDate(BuildContext context) async {
    // Only year and month picker ideally, but standard picker is fine for now
    // We pick a date, but only use Month/Year
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // Refresh auto-suggested values for the new month
      if (widget.record == null) {
        await _fetchAutoOvertime(picked.year, picked.month);
      }
    }
  }

  Future<void> _save() async {
    if (_settings == null) return;

    final normalHours = double.tryParse(_normalHoursController.text) ?? 0;
    final overtimeHours = double.tryParse(_overtimeHoursController.text) ?? 0;
    final nightHours = double.tryParse(_nightShiftHoursController.text) ?? 0;
    final weekendHours = double.tryParse(_weekendHoursController.text) ?? 0;
    final publicHolidayHours = double.tryParse(_publicHolidayController.text) ?? 0; // NEW
    final annualLeaveDays = double.tryParse(_annualLeaveController.text) ?? 0; // NEW
    final advance = double.tryParse(_advanceController.text) ?? 0;
    final otosanAllowance = _hasOtosan ? (double.tryParse(_otosanController.text) ?? 0) : 0.0;
    final holidayAllowance = _hasHolidayAllowance ? (double.tryParse(_holidayAllowanceController.text) ?? 0) : 0.0;
    final leaveAllowance = _hasLeaveAllowance ? (double.tryParse(_leaveAllowanceController.text) ?? 0) : 0.0;
    final tahsilAllowance = _hasTahsilAllowance ? (double.tryParse(_tahsilAllowanceController.text) ?? 0) : 0.0;
    final shoeAllowance = _hasShoeAllowance ? (double.tryParse(_shoeAllowanceController.text) ?? 0) : 0.0;
    final jobIndemnity = _hasJobIndemnity ? (double.tryParse(_jobIndemnityController.text) ?? 0) : 0.0;
    final tisAdvance = _hasTisAdvance ? (double.tryParse(_tisAdvanceController.text) ?? 0) : 0.0;

    SalaryRecord record;
    if (widget.record != null) {
      record = widget.record!;
      // Update fields
      record.year = _selectedDate.year;
      record.month = _selectedDate.month;
      record.normalHours = normalHours;
      record.overtimeHours = overtimeHours;
      record.nightShiftHours = nightHours;
      record.weekendHours = weekendHours;
      record.publicHolidayHours = publicHolidayHours; // NEW
      record.annualLeaveDays = annualLeaveDays; // NEW
      record.otosanAllowance = otosanAllowance; // NEW
      record.holidayAllowance = holidayAllowance;
      record.leaveAllowance = leaveAllowance;
      record.tahsilAllowance = tahsilAllowance;
      record.shoeAllowance = shoeAllowance;
      record.jobIndemnity = jobIndemnity;
      record.tisAdvance = tisAdvance;
      // Bonus is handled automatically in Service
      record.advanceAmount = advance;
    } else {
        // Check if record already exists for this month?
        final existing = DatabaseService.getSalaryRecord(_selectedDate.year, _selectedDate.month);
        if (existing != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bu ay için zaten bir kayıt var!')),
            );
            return;
        }

      record = SalaryRecord.create(
        year: _selectedDate.year,
        month: _selectedDate.month,
        normalHours: normalHours,
        overtimeHours: overtimeHours,
        nightShiftHours: nightHours,
        weekendHours: weekendHours,
        // Bonus handled by service
        advanceAmount: advance,
        publicHolidayHours: publicHolidayHours, // NEW
        annualLeaveDays: annualLeaveDays, // NEW
        otosanAllowance: otosanAllowance, // NEW
        holidayAllowance: holidayAllowance,
        leaveAllowance: leaveAllowance,
        tahsilAllowance: tahsilAllowance,
        shoeAllowance: shoeAllowance,
        jobIndemnity: jobIndemnity,
        tisAdvance: tisAdvance,
      );
    }

    // For new records, we must save to DB first to ensure it's in the Hive box
    // because SalaryService.calculateAndSave calls record.save()
    if (widget.record == null) {
        await DatabaseService.saveSalaryRecord(record);
    }
    
    await SalaryService.calculateAndSave(record, _settings!);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record != null ? 'Maaş Kaydını Düzenle' : 'Yeni Maaş Kaydı'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarih Seçimi
          InkWell(
            onTap: widget.record == null ? () => _selectDate(context) : null, // Prevent date change on edit for simplicity
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month),
                  const SizedBox(width: 16),
                  Text(
                    DateFormat('MMMM yyyy', 'tr_TR').format(_selectedDate),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (widget.record == null) const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          const Text('Çalışma Saatleri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          
          Row(children: [
             Expanded(child: _buildField('Normal Saat', _normalHoursController)),
             const SizedBox(width: 16),
             Expanded(child: _buildField('Fazla Mesai', _overtimeHoursController, suffix: '(Oto)')),
          ]),
          
          Row(children: [
             Expanded(child: _buildField('Gece (Saat)', _nightShiftHoursController)),
             const SizedBox(width: 16),
             Expanded(child: _buildField('Hafta Tatili', _weekendHoursController)),
          ]),

          // NEW ROW
          Row(children: [
             Expanded(child: _buildField('Genel Tatil', _publicHolidayController)),
             const SizedBox(width: 16),
             Expanded(child: _buildField('Yıllık İzin (Gün)', _annualLeaveController)),
          ]),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              const Text('Avans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _advanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Tutar (TL)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          ExpansionTile(
            title: const Text('Ek Ödemeler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            initiallyExpanded: false,
            tilePadding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 16),
              
              _buildSwitchField(
                title: 'İşveren Katkısı',
                value: _hasOtosan,
                onChanged: (val) => setState(() {
                    _hasOtosan = val;
                    if (!val) _otosanController.text = '0';
                }),
                controller: _otosanController,
              ),
              
              
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                ),
                child: Column(children: [
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bayram Harçlığı', style: TextStyle(fontSize: 16)),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _hasHolidayAllowance,
                            onChanged: (val) {
                                setState(() {
                                    _hasHolidayAllowance = val;
                                    if (!val) _holidayAllowanceController.text = '0';
                                });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_hasHolidayAllowance)
                    Column(
                        children: [
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                    children: [
                                        ActionChip(
                                            avatar: const Icon(Icons.nightlight_round, size: 16),
                                            label: const Text('Ramazan'), 
                                            onPressed: () => _holidayAllowanceController.text = SocialService.getAmount('ramazan').toString()
                                        ),
                                        const SizedBox(width: 8),
                                        ActionChip(
                                            avatar: const Icon(Icons.whatshot, size: 16),
                                            label: const Text('Kurban'), 
                                            onPressed: () => _holidayAllowanceController.text = SocialService.getAmount('kurban').toString()
                                        ),
                                    ]
                                ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                    controller: _holidayAllowanceController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(labelText: 'Tutar (TL)', border: OutlineInputBorder()),
                                ),
                            )
                        ]
                    )
                ]),
              ),
              
              _buildSwitchField(
                title: 'Görev Tazminatı',
                value: _hasJobIndemnity,
                onChanged: (val) => setState(() {
                    _hasJobIndemnity = val;
                    if (!val) _jobIndemnityController.text = '0';
                }),
                controller: _jobIndemnityController,
              ),



              _buildSwitchField(
                title: 'Yıllık İzin Harçlığı',
                value: _hasLeaveAllowance,
                onChanged: (val) => setState(() {
                    _hasLeaveAllowance = val;
                    if (val) {
                        _leaveAllowanceController.text = SocialService.leaveAmount.toString();
                    } else {
                        _leaveAllowanceController.text = '0';
                    }
                }),
                controller: _leaveAllowanceController,
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                ),
                child: Column(children: [
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tahsil Yardımı', style: TextStyle(fontSize: 16)),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _hasTahsilAllowance,
                            onChanged: (val) {
                                setState(() {
                                    _hasTahsilAllowance = val;
                                    if (!val) _tahsilAllowanceController.text = '0';
                                });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_hasTahsilAllowance)
                    Column(
                        children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Text('Çocuk Sayısı Giriniz:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ),
                            _buildEducationCounter('Anaokulu', _countAna, (val) {
                                setState(() { _countAna = val; _updateTahsilTotal(); });
                            }),
                            _buildEducationCounter('İlkokul', _countIlk, (val) {
                                setState(() { _countIlk = val; _updateTahsilTotal(); });
                            }),
                            _buildEducationCounter('Ortaokul', _countOrta, (val) {
                                setState(() { _countOrta = val; _updateTahsilTotal(); });
                            }),
                            _buildEducationCounter('Lise', _countLise, (val) {
                                setState(() { _countLise = val; _updateTahsilTotal(); });
                            }),
                            _buildEducationCounter('Üniversite', _countUni, (val) {
                                setState(() { _countUni = val; _updateTahsilTotal(); });
                            }),
                            
                            Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                    controller: _tahsilAllowanceController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(labelText: 'Tutar (TL)', border: OutlineInputBorder()),
                                ),
                            )
                        ]
                    )
                ]),
              ),

              _buildSwitchField(
                title: 'Ayakkabı Çeki',
                value: _hasShoeAllowance,
                onChanged: (val) => setState(() {
                    _hasShoeAllowance = val;
                    if (val) {
                        _shoeAllowanceController.text = SocialService.shoeAmount.toString();
                    } else {
                        _shoeAllowanceController.text = '0';
                    }
                }),
                controller: _shoeAllowanceController,
              ),

              _buildSwitchField(
                title: 'TİS Toplu Ödeme',
                value: _hasTisAdvance,
                onChanged: (val) => setState(() {
                    _hasTisAdvance = val;
                    if (!val) _tisAdvanceController.text = '0';
                }),
                controller: _tisAdvanceController,
              ),


            ],
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
            ),
            child: const Text('HESAPLA VE KAYDET', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchField({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16)),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
          if (value)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Tutar (TL)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _updateTahsilTotal() {
    double total = (_countAna * SocialService.getEducationAmount('anasinifi')) +
                   (_countIlk * SocialService.getEducationAmount('ilkokul')) +
                   (_countOrta * SocialService.getEducationAmount('ortaokul')) +
                   (_countLise * SocialService.getEducationAmount('lise')) +
                   (_countUni * SocialService.getEducationAmount('yuksek'));
    
    _tahsilAllowanceController.text = total.toStringAsFixed(2);
  }

  Widget _buildEducationCounter(String label, int count, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: count > 0 ? () => onChanged(count - 1) : null,
                visualDensity: VisualDensity.compact,
              ),
              Text('$count', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                onPressed: () => onChanged(count + 1),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
