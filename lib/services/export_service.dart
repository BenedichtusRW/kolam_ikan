import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel_pkg;
import '../utils/mock_data_generator.dart';

class ExportService {
  // Save bytes to Downloads (Android) when possible, otherwise to app documents.
  static Future<String?> saveFileBytes(Uint8List bytes, String fileName) async {
    try {
      if (Platform.isAndroid) {
        bool canWrite = false;
        try {
          if (await Permission.storage.isGranted)
            canWrite = true;
          else {
            final status = await Permission.storage.request();
            if (status.isGranted)
              canWrite = true;
            else {
              final mgr = await Permission.manageExternalStorage.request();
              if (mgr.isGranted) canWrite = true;
            }
          }
        } catch (_) {
          canWrite = false;
        }

        if (canWrite) {
          try {
            final downloads = Directory('/storage/emulated/0/Download');
            Directory? target = downloads;
            if (!await downloads.exists()) {
              target = await getExternalStorageDirectory();
            }
            if (target != null) {
              final file = File('${target.path}/$fileName');
              await file.writeAsBytes(bytes);
              return file.path;
            }
          } catch (_) {
            // fallthrough to app documents
          }
        }
      }

      final appDoc = await getApplicationDocumentsDirectory();
      final file = File('${appDoc.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  // Export as simple text-based PDF placeholder (CSV-like content inside .pdf)
  static Future<String?> exportPDF({
    required BuildContext context,
    required List<String> pondIds,
    DateTime? date,
  }) async {
    try {
      final selDate = date ?? DateTime.now();
      final sb = StringBuffer();
      sb.writeln('Laporan Riwayat Gabungan - ${_formatDate(selDate)}');
      for (final pid in pondIds) {
        final mock = MockDataGenerator.generateDailyMockData(
          date: selDate,
          pondId: pid,
          dataPointsPerHour: 6,
        );
        sb.writeln('\nKolam: $pid');
        sb.writeln('Waktu,Suhu,pH,Oksigen');
        for (final d in mock) {
          sb.writeln(
            '${d.timestamp.toIso8601String()},${d.temperature.toStringAsFixed(2)},${d.phLevel.toStringAsFixed(2)},${d.oxygen.toStringAsFixed(2)}',
          );
        }
      }

      final bytes = Uint8List.fromList(utf8.encode(sb.toString()));
      final fileName = 'Laporan_History_${selDate.millisecondsSinceEpoch}.pdf';
      final saved = await saveFileBytes(bytes, fileName);
      return saved;
    } catch (e) {
      return null;
    }
  }

  // Export as Excel with one sheet per pond
  static Future<String?> exportExcel({
    required BuildContext context,
    required List<String> pondIds,
    DateTime? date,
  }) async {
    try {
      final selDate = date ?? DateTime.now();
      var excel = excel_pkg.Excel.createExcel();

      for (final pid in pondIds) {
        final sheetName = 'Pond_$pid';
        excel_pkg.Sheet sheet = excel[sheetName];

        sheet.cell(excel_pkg.CellIndex.indexByString('A1')).value =
            excel_pkg.TextCellValue('Laporan Riwayat - $pid');
        sheet.cell(excel_pkg.CellIndex.indexByString('A2')).value =
            excel_pkg.TextCellValue('Tanggal: ${_formatDate(selDate)}');
        sheet.cell(excel_pkg.CellIndex.indexByString('A4')).value =
            excel_pkg.TextCellValue('Waktu');
        sheet.cell(excel_pkg.CellIndex.indexByString('B4')).value =
            excel_pkg.TextCellValue('Suhu (°C)');
        sheet.cell(excel_pkg.CellIndex.indexByString('C4')).value =
            excel_pkg.TextCellValue('pH');
        sheet.cell(excel_pkg.CellIndex.indexByString('D4')).value =
            excel_pkg.TextCellValue('Oksigen');

        final dataList = MockDataGenerator.generateDailyMockData(
          date: selDate,
          pondId: pid,
          dataPointsPerHour: 6,
        );

        for (int i = 0; i < dataList.length; i++) {
          final row = i + 5;
          final d = dataList[i];
          sheet.cell(excel_pkg.CellIndex.indexByString('A$row')).value =
              excel_pkg.TextCellValue(d.timestamp.toIso8601String());
          sheet.cell(excel_pkg.CellIndex.indexByString('B$row')).value =
              excel_pkg.TextCellValue(d.temperature.toStringAsFixed(2));
          sheet.cell(excel_pkg.CellIndex.indexByString('C$row')).value =
              excel_pkg.TextCellValue(d.phLevel.toStringAsFixed(2));
          sheet.cell(excel_pkg.CellIndex.indexByString('D$row')).value =
              excel_pkg.TextCellValue(d.oxygen.toStringAsFixed(2));
        }
      }

      final encoded = excel.encode();
      if (encoded == null) return null;
      final bytes = Uint8List.fromList(encoded);
      final fileName =
          'Laporan_History_${(date ?? DateTime.now()).millisecondsSinceEpoch}.xlsx';
      final saved = await saveFileBytes(bytes, fileName);
      return saved;
    } catch (e) {
      return null;
    }
  }

  static String _formatDate(DateTime date) {
    List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
