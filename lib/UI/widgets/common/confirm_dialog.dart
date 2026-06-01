// lib/ui/widgets/common/confirm_dialog.dart
import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final String cancelLabel;

  const ConfirmDialog({
    required this.title,
    required this.content,
    this.confirmLabel = 'OK',
    this.cancelLabel = 'Cancel',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTextStyles.sectionTitle),
      content: Text(content, style: AppTextStyles.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

class DeleteConfirmDialog extends ConfirmDialog {
  const DeleteConfirmDialog({
    super.key,
    super.title = 'Delete',
    super.content = 'Are you sure you want to delete this item?',
  }) : super(confirmLabel: 'Delete', cancelLabel: 'Cancel');
}
