/// Data returned when the user presses "Done" in [PopupAddTransaction].
///
/// Contains the user-selected category, note, and transaction id
/// so the caller can update the transaction and clear the Needs Attention flag.
class TransactionResultData {
  final String transactionId;
  final String selectedCategory;
  final String note;

  const TransactionResultData({
    required this.transactionId,
    required this.selectedCategory,
    required this.note,
  });
}
