import 'sms_event.dart';

/// Classification of a bank transaction type from an SMS.
enum BankTransactionType {
  debit,
  credit,
  atm,
  upi,
  imps,
  neft,
  rtgs,
  card,
  wallet,
  unknown,
}

/// The final result of processing an SMS through the full pipeline.
///
/// Contains the classified transaction data extracted from the SMS,
/// along with the raw source data and confidence score.
class ProcessingResult {
  /// Whether this SMS is identified as a financial transaction.
  final bool isTransaction;

  /// Detected bank name (e.g. "HDFC", "ICICI"), or null if unknown.
  final String? bank;

  /// Transaction amount, or null if not detected.
  final double? amount;

  /// Merchant or payee name, or null if not detected.
  final String? merchant;

  /// Bank reference / transaction ID, or null if not detected.
  final String? referenceNumber;

  /// Available balance after the transaction, or null if not detected.
  final double? balance;

  /// Type of the bank transaction.
  final BankTransactionType transactionType;

  /// Raw SMS body that was processed.
  final String rawSms;

  /// SMS sender address.
  final String sender;

  /// SMS timestamp (epoch millis).
  final int timestamp;

  /// Confidence score from 0.0 to 1.0.
  final double confidence;

  ProcessingResult({
    required this.isTransaction,
    this.bank,
    this.amount,
    this.merchant,
    this.referenceNumber,
    this.balance,
    this.transactionType = BankTransactionType.unknown,
    required this.rawSms,
    required this.sender,
    required this.timestamp,
    this.confidence = 0.0,
  });

  /// Build a [ProcessingResult] from an [SmsEvent] and parsed fields.
  factory ProcessingResult.fromSmsEvent({
    required SmsEvent event,
    required bool isTransaction,
    String? bank,
    double? amount,
    String? merchant,
    String? referenceNumber,
    double? balance,
    BankTransactionType transactionType = BankTransactionType.unknown,
    double confidence = 0.0,
  }) {
    return ProcessingResult(
      isTransaction: isTransaction,
      bank: bank,
      amount: amount,
      merchant: merchant,
      referenceNumber: referenceNumber,
      balance: balance,
      transactionType: transactionType,
      rawSms: event.body,
      sender: event.sender,
      timestamp: event.timestamp,
      confidence: confidence,
    );
  }

  Map<String, dynamic> toJson() => {
        'isTransaction': isTransaction,
        'bank': bank,
        'amount': amount,
        'merchant': merchant,
        'referenceNumber': referenceNumber,
        'balance': balance,
        'transactionType': transactionType.name,
        'rawSms': rawSms,
        'sender': sender,
        'timestamp': timestamp,
        'confidence': confidence,
      };

  @override
  String toString() =>
      'ProcessingResult(isTransaction: $isTransaction, bank: $bank, '
      'amount: $amount, merchant: $merchant, type: ${transactionType.name}, '
      'confidence: $confidence)';
}
