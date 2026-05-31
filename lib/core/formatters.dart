// Reusable formatting helpers for compact numeric display
String compactNumber(double val) {
  final v = val.abs();
  if (v >= 10000000) {
    final d = val / 10000000.0;
    final s = (d.abs() < 10 && d % 1 != 0)
        ? d.toStringAsFixed(1)
        : d.toStringAsFixed(0);
    return '${s}Cr';
  }
  if (v >= 100000) {
    final d = val / 100000.0;
    final s = (d.abs() < 10 && d % 1 != 0)
        ? d.toStringAsFixed(1)
        : d.toStringAsFixed(0);
    return '${s}L';
  }
  if (v >= 1000) {
    final d = val / 1000.0;
    final s = (d.abs() < 10 && d % 1 != 0)
        ? d.toStringAsFixed(1)
        : d.toStringAsFixed(0);
    return '${s}K';
  }
  return val.toStringAsFixed(0);
}

String formatCompactCurrency(double val, {String symbol = '₹'}) {
  final sign = val < 0 ? '-' : '';
  final absVal = val < 0 ? -val : val;
  return '$sign$symbol${compactNumber(absVal)}'.replaceAll('  ', ' ');
}
