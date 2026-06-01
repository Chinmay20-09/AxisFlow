// lib/ui/widgets/common/loading_placeholder.dart
import 'package:flutter/material.dart';
import 'package:axisflow/core/constants/app_spacing.dart';

class LoadingPlaceholder extends StatelessWidget {
  final String? message;
  const LoadingPlaceholder({this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(message!),
          ],
        ],
      ),
    );
  }
}
