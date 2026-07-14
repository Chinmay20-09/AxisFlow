// lib/ui/widgets/tiles/export_import_tile.dart
import 'package:flutter/material.dart';
import 'package:axisflow/core/constants/app_spacing.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';

class ExportImportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const ExportImportTile({
    required this.icon,
    required this.title,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}
