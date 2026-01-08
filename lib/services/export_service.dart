import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/leave_type.dart';
import 'database_service.dart';

class ExportService {
  static pw.Font? _turkishFont;
  static pw.Font? _turkishFontBold;

  /// Load Turkish-compatible font
  static Future<pw.Font> _getTurkishFont() async {
    if (_turkishFont != null) return _turkishFont!;
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    _turkishFont = pw.Font.ttf(fontData);
    return _turkishFont!;
  }

  /// Export overtime data to PDF and save to device
  static Future<String?> exportToPDF(int year) async {
    final monthNames = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];

    final settings = DatabaseService.getSettings();
    
    // Load Turkish font
    final turkishFont = await _getTurkishFont();
    
    final pdf = pw.Document();

    // Get monthly totals
    final monthlyTotals = <int, double>{};
    double yearlyTotal = 0;
    for (int m = 1; m <= 12; m++) {
      final total = DatabaseService.getMonthlyTotal(year, m);
      monthlyTotals[m] = total;
      yearlyTotal += total;
    }

    // Get all overtimes for the year
    final overtimes = DatabaseService.getAllOvertimes()
        .where((o) => o.date.year == year)
        .toList();
    overtimes.sort((a, b) => a.date.compareTo(b.date));

    // Create theme with Turkish font
    final theme = pw.ThemeData.withFont(
      base: turkishFont,
      bold: turkishFont,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: theme,
        build: (context) => [
          // Header
          pw.Center(
            child: pw.Text(
              '$year Yılı Fazla Mesai Raporu',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          if (settings.fullName != null)
            pw.Center(
              child: pw.Text(
                settings.fullName!,
                style: const pw.TextStyle(fontSize: 14),
              ),
            ),
          pw.SizedBox(height: 24),

          // Monthly Summary
          pw.Text(
            'Aylık Özet',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellPadding: const pw.EdgeInsets.all(8),
            data: [
              ['Ay', 'Mesai Saati'],
              ...monthlyTotals.entries
                  .where((e) => e.value > 0)
                  .map((e) => [monthNames[e.key - 1], '${e.value} saat']),
              ['Yıllık Toplam', '$yearlyTotal saat'],
            ],
          ),
          pw.SizedBox(height: 24),

          // Detailed records
          if (overtimes.isNotEmpty) ...[
            pw.Text(
              'Detaylı Kayıtlar',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellPadding: const pw.EdgeInsets.all(8),
              data: [
                ['Tarih', 'Saat', 'Not'],
                ...overtimes.map((o) => [
                      DateFormat('dd.MM.yyyy').format(o.date),
                      '${o.hours} saat',
                      o.note ?? '-',
                    ]),
              ],
            ),
          ],

          // Footer
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'FOPR - Fazla Mesai Takip',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.Text(
                'Oluşturulma: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          ),
        ],
      ),
    );

    // Save to Downloads folder
    final directory = await getExternalStorageDirectory();
    final downloadsPath = directory?.path ?? (await getTemporaryDirectory()).path;
    final fileName = 'fopr_mesai_${year}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('$downloadsPath/$fileName');
    await file.writeAsBytes(await pdf.save());

    // Open the file
    await OpenFilex.open(file.path);

    return file.path;
  }

  /// Share a text summary
  static Future<void> shareTextSummary(int year) async {
    final monthNames = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];

    final settings = DatabaseService.getSettings();
    final buffer = StringBuffer();

    buffer.writeln('📊 $year Yılı Fazla Mesai Raporu');
    if (settings.fullName != null) {
      buffer.writeln('👤 ${settings.fullName}');
    }
    if (settings.employeeId != null && settings.employeeId!.isNotEmpty) {
      buffer.writeln('🆔 Sicil No: ${settings.employeeId}');
    }
    buffer.writeln('─' * 20);
    buffer.writeln();

    double yearlyTotal = 0;
    for (int m = 1; m <= 12; m++) {
      final total = DatabaseService.getMonthlyTotal(year, m);
      if (total > 0) {
        buffer.writeln('${monthNames[m - 1]}: ${total.toStringAsFixed(1)} saat');
        yearlyTotal += total;
      }
    }

    buffer.writeln();
    buffer.writeln('─' * 20);
    buffer.writeln('📈 Yıllık Toplam: ${yearlyTotal.toStringAsFixed(1)} saat');
    buffer.writeln();
    buffer.writeln('FOPR ile oluşturuldu');

    await Share.share(buffer.toString());
  }

  // ============ Leave Export Methods ============

  /// Export leave data to PDF and save to device
  static Future<String?> exportLeaveToPDF(int year) async {
    final settings = DatabaseService.getSettings();
    final turkishFont = await _getTurkishFont();
    
    final entitlement = DatabaseService.calculateAnnualEntitlement();
    final used = DatabaseService.getUsedAnnualLeaveDays(year);
    final remaining = DatabaseService.getRemainingAnnualLeaveDays(year);
    final leaves = DatabaseService.getLeavesByYear(year);
    leaves.sort((a, b) => a.startDate.compareTo(b.startDate));

    final pdf = pw.Document();

    final theme = pw.ThemeData.withFont(
      base: turkishFont,
      bold: turkishFont,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: theme,
        build: (context) => [
          // Header
          pw.Center(
            child: pw.Text(
              '$year Yılı İzin Raporu',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          if (settings.fullName != null)
            pw.Center(
              child: pw.Text(
                settings.fullName!,
                style: const pw.TextStyle(fontSize: 14),
              ),
            ),
          if (settings.employeeId != null && settings.employeeId!.isNotEmpty)
            pw.Center(
              child: pw.Text(
                'Sicil: ${settings.employeeId}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
          pw.SizedBox(height: 24),

          // Summary
          pw.Text(
            'İzin Özeti',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellPadding: const pw.EdgeInsets.all(8),
            data: [
              ['Hak Ediş', 'Kullanılan', 'Kalan'],
              ['$entitlement gün', '${used.toStringAsFixed(0)} gün', '${remaining.toStringAsFixed(0)} gün'],
            ],
          ),
          pw.SizedBox(height: 24),

          // Leave type breakdown
          pw.Text(
            'İzin Türü Dağılımı',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellPadding: const pw.EdgeInsets.all(8),
            data: [
              ['İzin Türü', 'Gün'],
              ...leaves
                  .fold<Map<String, double>>({}, (map, l) {
                    final name = l.type.displayName;
                    map[name] = (map[name] ?? 0) + l.days;
                    return map;
                  })
                  .entries
                  .map((e) => [e.key, '${e.value.toStringAsFixed(e.value == e.value.toInt() ? 0 : 1)} gün']),
            ],
          ),
          pw.SizedBox(height: 24),

          // Detailed records
          if (leaves.isNotEmpty) ...[
            pw.Text(
              'Detaylı Kayıtlar',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellPadding: const pw.EdgeInsets.all(8),
              data: [
                ['Tarih', 'Tür', 'Gün', 'Not'],
                ...leaves.map((l) => [
                      DateFormat('dd.MM.yyyy').format(l.startDate),
                      l.type.displayName,
                      '${l.days.toStringAsFixed(l.days == l.days.toInt() ? 0 : 1)}',
                      l.note ?? '-',
                    ]),
              ],
            ),
          ],

          // Footer
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'FOPR - İzin Takip',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.Text(
                'Oluşturulma: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          ),
        ],
      ),
    );

    // Save to Downloads folder
    final directory = await getExternalStorageDirectory();
    final downloadsPath = directory?.path ?? (await getTemporaryDirectory()).path;
    final fileName = 'fopr_izin_${year}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('$downloadsPath/$fileName');
    await file.writeAsBytes(await pdf.save());

    // Open the file
    await OpenFilex.open(file.path);

    return file.path;
  }

  /// Share leave summary as text
  static Future<void> shareLeaveSummary(int year) async {
    final settings = DatabaseService.getSettings();
    final entitlement = DatabaseService.calculateAnnualEntitlement();
    final used = DatabaseService.getUsedAnnualLeaveDays(year);
    final remaining = DatabaseService.getRemainingAnnualLeaveDays(year);
    final leaves = DatabaseService.getLeavesByYear(year);

    final buffer = StringBuffer();

    buffer.writeln('📋 $year Yılı İzin Raporu');
    if (settings.fullName != null) {
      buffer.writeln('👤 ${settings.fullName}');
    }
    if (settings.employeeId != null && settings.employeeId!.isNotEmpty) {
      buffer.writeln('🆔 Sicil No: ${settings.employeeId}');
    }
    buffer.writeln('─' * 20);
    buffer.writeln();

    buffer.writeln('📊 Özet');
    buffer.writeln('  Hak Ediş: $entitlement gün');
    buffer.writeln('  Kullanılan: ${used.toStringAsFixed(0)} gün');
    buffer.writeln('  Kalan: ${remaining.toStringAsFixed(0)} gün');
    buffer.writeln();

    // Group by type
    final typeMap = <String, double>{};
    for (final l in leaves) {
      final name = l.type.displayName;
      typeMap[name] = (typeMap[name] ?? 0) + l.days;
    }

    if (typeMap.isNotEmpty) {
      buffer.writeln('📝 İzin Türleri');
      for (final entry in typeMap.entries) {
        buffer.writeln('  ${entry.key}: ${entry.value.toStringAsFixed(0)} gün');
      }
    }

    buffer.writeln();
    buffer.writeln('─' * 20);
    buffer.writeln('FOPR ile oluşturuldu');

    await Share.share(buffer.toString());
  }

  /// Convert Turkish characters to ASCII for PDF compatibility
  static String _toAscii(String text) {
    return text
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'I')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'G')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'U')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 'S')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'O')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'C');
  }
}
