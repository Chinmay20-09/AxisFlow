import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/data/services/import_service.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';
import 'package:axisflow/core/constants/app_spacing.dart';

class ImportScreen extends StatefulWidget {
  final TransactionController controller;
  const ImportScreen({super.key, required this.controller});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  String? _filePath;
  bool _loading = false;
  ImportResult? _preview;

  Future<void> _pickFile() async {
    setState(() => _loading = true);
    try {
      final res = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (res == null || res.files.isEmpty) return;
      final path = res.files.single.path;
      if (path == null) return;
      final file = File(path);
      final content = await file.readAsString();
      final preview = await ImportService.previewCsv(content);
      setState(() {
        _filePath = path;
        _preview = preview;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to read file: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _doImport() async {
    if (_preview == null) return;
    setState(() => _loading = true);
    try {
      final result = await ImportService.importTransactions(
        _preview!.toImport,
        onImported: () => widget.controller.load(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported ${result.importedCount} transactions'),
          ),
        );
        // Optionally show analysis
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted){
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import CSV')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CSV Import', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Choose a CSV file exported by AxisFlow. The file will be validated and a preview will be shown before importing.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _loading ? null : _pickFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Select CSV File'),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      if (_filePath != null)
                        Expanded(
                          child: Text(
                            _filePath!,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_preview != null) ...[
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preview', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Total rows found: ${_preview!.totalRows}',
                      style: AppTextStyles.body,
                    ),
                    Text(
                      'Valid rows: ${_preview!.validRows}',
                      style: AppTextStyles.body,
                    ),
                    Text(
                      'Invalid rows: ${_preview!.invalidRows}',
                      style: AppTextStyles.body,
                    ),
                    Text(
                      'Duplicate rows: ${_preview!.duplicateRows}',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Import analysis:', style: AppTextStyles.body),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Total income: ${_preview!.analysis['totalIncome'] ?? 0}',
                      style: AppTextStyles.body,
                    ),
                    Text(
                      'Total expense: ${_preview!.analysis['totalExpense'] ?? 0}',
                      style: AppTextStyles.body,
                    ),
                    Text(
                      'Top expense category: ${_preview!.analysis['topExpenseCategory'] ?? '-'}',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _loading ? null : _doImport,
                          child: const Text('Import'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (_loading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
