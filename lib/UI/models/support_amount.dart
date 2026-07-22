/// A predefined or custom donation amount option
/// displayed on the Support & Development screen.
class SupportAmount {
  final String id;
  final String label;
  final double amount;
  final bool isCustom;

  const SupportAmount({
    required this.id,
    required this.label,
    required this.amount,
    this.isCustom = false,
  });

  /// Predefined donation tiers shown as selectable cards.
  static const List<SupportAmount> defaults = [
    SupportAmount(id: 'supporter', label: 'Supporter', amount: 3),
    SupportAmount(id: 'backer', label: 'Backer', amount: 5),
    SupportAmount(id: 'patron', label: 'Patron', amount: 10),
    SupportAmount(id: 'angel', label: 'Angel', amount: 25),
  ];

  /// The "Custom amount" option shown below the grid.
  static const custom = SupportAmount(
    id: 'custom',
    label: 'Custom',
    amount: 0,
    isCustom: true,
  );
}
