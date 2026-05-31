import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:axisflow/core/constants/app_strings.dart';
import '../models/transaction_model.dart';

class ExportService {
  static Future<bool> exportTransactions(List<Transaction> transactions) async {
    try {
      // Header row
      final rows = <List<dynamic>>[
        ['Date', 'Time', 'Note', 'Amount', 'Category', 'Type', 'State'],
      ];
      // Data rows
      for (final tx in transactions) {
        rows.add([
          formatDate(tx.createdAt),
          formatTime(tx.createdAt),
          tx.note,
          tx.amount,
          CategoryHelper.cleanCategory(tx.category),
          tx.type.name,
          tx.state.name,
        ]);
      }

      // Safe CSV generation
      final csv = rows
          .map((row) {
            return row
                .map((cell) {
                  final value = cell.toString().replaceAll('"', '""');
                  return '"$value"';
                })
                .join(',');
          })
          .join('\n');

      final directory = await getTemporaryDirectory();

      final file = File(
        '${directory.path}/axisflow_export_${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}_${DateTime.now().hour}-${DateTime.now().minute}.csv',
      );

      await file.writeAsString(csv);

      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));

      return true;
    } catch (e, stackTrace) {
      debugPrint('CSV Export Failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      return false;
    }
  }
}
