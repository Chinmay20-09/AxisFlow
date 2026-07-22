import 'package:flutter_test/flutter_test.dart';
import 'package:axisflow/automation/sms/parser/sms_field_extractor.dart';

void main() {
  group('SmsFieldExtractor.extractAmount', () {
    // ── Currency-prefixed amounts ──────────────────────────────────────────

    test('extracts Rs. prefixed amount', () {
      expect(
        SmsFieldExtractor.extractAmount('Spent Rs.1500 at AMAZON on 12-03-2025'),
        closeTo(1500, 0.01),
      );
    });

    test('extracts Rs prefixed amount (no dot)', () {
      expect(
        SmsFieldExtractor.extractAmount('Rs 250 debited from a/c XXXX1234'),
        closeTo(250, 0.01),
      );
    });

    test('extracts Rs. with space and decimal', () {
      expect(
        SmsFieldExtractor.extractAmount('Rs. 250.50 spent at SWIGGY'),
        closeTo(250.50, 0.01),
      );
    });

    test('extracts ₹ prefixed amount', () {
      expect(
        SmsFieldExtractor.extractAmount('₹1500 credited to a/c XXXX5678'),
        closeTo(1500, 0.01),
      );
    });

    test('extracts ₹ with space', () {
      expect(
        SmsFieldExtractor.extractAmount('₹ 500 deposited in a/c'),
        closeTo(500, 0.01),
      );
    });

    test('extracts INR prefixed amount', () {
      expect(
        SmsFieldExtractor.extractAmount('INR 50000 credited by NEFT'),
        closeTo(50000, 0.01),
      );
    });

    test('extracts amount with thousand separators', () {
      expect(
        SmsFieldExtractor.extractAmount('Rs. 1,50,000 credited to a/c'),
        closeTo(150000, 0.01),
      );
    });

    // ── Action-based amounts ───────────────────────────────────────────────

    test('extracts "debited by" amount', () {
      expect(
        SmsFieldExtractor.extractAmount('debited by 1500 from A/C XXXX1234'),
        closeTo(1500, 0.01),
      );
    });

    test('extracts "credited by" amount', () {
      expect(
        SmsFieldExtractor.extractAmount('credited by 5000 to A/C XXXX5678'),
        closeTo(5000, 0.01),
      );
    });

    test('extracts "debited with" amount', () {
      expect(
        SmsFieldExtractor.extractAmount('debited with 250 at AMAZON'),
        closeTo(250, 0.01),
      );
    });

    test('extracts "credited with" amount', () {
      expect(
        SmsFieldExtractor.extractAmount('credited with 10000 via NEFT'),
        closeTo(10000, 0.01),
      );
    });

    // ── Account-specific amounts ───────────────────────────────────────────

    test('extracts "A/C XXXX debited by" amount', () {
      expect(
        SmsFieldExtractor.extractAmount(
            'A/C XXXX1234 debited by 1500 on 15-03-2025'),
        closeTo(1500, 0.01),
      );
    });

    test('extracts "Account XX credited by" amount', () {
      expect(
        SmsFieldExtractor.extractAmount(
            'Account XX5678 credited by 5000 on 15-03-2025'),
        closeTo(5000, 0.01),
      );
    });

    // ── Spent/paid/withdrawn amounts ───────────────────────────────────────

    test('extracts "spent" amount', () {
      expect(
        SmsFieldExtractor.extractAmount('spent Rs.1500 at AMAZON'),
        closeTo(1500, 0.01),
      );
    });

    test('extracts "paid" amount', () {
      expect(
        SmsFieldExtractor.extractAmount('paid Rs. 250 at SWIGGY'),
        closeTo(250, 0.01),
      );
    });

    test('extracts "withdrawn" amount', () {
      expect(
        SmsFieldExtractor.extractAmount('withdrawn Rs. 500 at ATM'),
        closeTo(500, 0.01),
      );
    });

    // ── Amount keyword patterns ────────────────────────────────────────────

    test('extracts "amount" keyword amount', () {
      expect(
        SmsFieldExtractor.extractAmount('amount Rs.1500 is debited'),
        closeTo(1500, 0.01),
      );
    });

    test('extracts "amt" keyword amount', () {
      expect(
        SmsFieldExtractor.extractAmount('amt 500 credited'),
        closeTo(500, 0.01),
      );
    });

    test('extracts "amount is" keyword amount', () {
      expect(
        SmsFieldExtractor.extractAmount('amount is Rs. 2500'),
        closeTo(2500, 0.01),
      );
    });

    // ── Real-world examples ────────────────────────────────────────────────

    test('extracts amount from SBI SMS (debited)', () {
      // SBI: "Rs.1500 debited from a/c XX1234 on 15-03-2025"
      expect(
        SmsFieldExtractor.extractAmount(
            'Rs.1500 debited from a/c XX1234 on 15-03-2025'),
        closeTo(1500, 0.01),
      );
    });

    test('extracts amount from HDFC SMS (credited)', () {
      // HDFC: "INR 50000 credited to a/c XX5678 on 12-03-2025"
      expect(
        SmsFieldExtractor.extractAmount(
            'INR 50000 credited to a/c XX5678 on 12-03-2025'),
        closeTo(50000, 0.01),
      );
    });

    test('extracts amount from Axis SMS', () {
      // Axis: "A/C XX4321 debited by 1500 at POS"
      expect(
        SmsFieldExtractor.extractAmount('A/C XX4321 debited by 1500 at POS'),
        closeTo(1500, 0.01),
      );
    });

    test('extracts amount from ICICI SMS', () {
      // ICICI: "Rs.2500 spent at AMAZON on ICICI Bank Credit Card"
      expect(
        SmsFieldExtractor.extractAmount(
            'Rs.2500 spent at AMAZON on ICICI Bank Credit Card'),
        closeTo(2500, 0.01),
      );
    });

    test('extracts amount from Kotak SMS (UPI)', () {
      // Kotak: "UPI transaction of Rs. 350 to GOOGLE PAY"
      expect(
        SmsFieldExtractor.extractAmount(
            'UPI transaction of Rs. 350 to GOOGLE PAY'),
        closeTo(350, 0.01),
      );
    });

    test('extracts amount from PNB SMS', () {
      // PNB: "Rs.2000 credited to A/C XX7890 by NEFT"
      expect(
        SmsFieldExtractor.extractAmount(
            'Rs.2000 credited to A/C XX7890 by NEFT'),
        closeTo(2000, 0.01),
      );
    });

    test('extracts amount from Canara Bank SMS', () {
      // Canara: "A/C XX3456 credited with 7500 on 20-03-2025"
      expect(
        SmsFieldExtractor.extractAmount(
            'A/C XX3456 credited with 7500 on 20-03-2025'),
        closeTo(7500, 0.01),
      );
    });

    test('extracts amount from Union Bank SMS', () {
      // Union Bank: "debited by 1200 at SWIGGY from A/C XX9012"
      expect(
        SmsFieldExtractor.extractAmount(
            'debited by 1200 at SWIGGY from A/C XX9012'),
        closeTo(1200, 0.01),
      );
    });

    // ── Edge cases ─────────────────────────────────────────────────────────

    test('returns null for empty body', () {
      expect(SmsFieldExtractor.extractAmount(''), isNull);
    });

    test('returns null for body with no amount', () {
      expect(
        SmsFieldExtractor.extractAmount('Your OTP is 123456'),
        isNull,
      );
    });

    test('returns null for body with only phone numbers', () {
      expect(
        SmsFieldExtractor.extractAmount('Contact 9876543210 for support'),
        isNull,
      );
    });
  });

  group('SmsFieldExtractor.extractMerchant', () {
    test('extracts merchant after "at" keyword', () {
      expect(
        SmsFieldExtractor.extractMerchant('Rs.1500 spent at AMAZON'),
        'AMAZON',
      );
    });

    test('extracts merchant after "to" keyword', () {
      expect(
        SmsFieldExtractor.extractMerchant('paid to SWIGGY via UPI'),
        'SWIGGY',
      );
    });

    test('extracts merchant after "paid to"', () {
      expect(
        SmsFieldExtractor.extractMerchant('paid to AMAZON PAY on 12-03'),
        'AMAZON PAY',
      );
    });

    test('extracts merchant after "transfer to"', () {
      expect(
        SmsFieldExtractor.extractMerchant('transfer to ZOMATO via UPI'),
        'ZOMATO',
      );
    });

    test('extracts merchant after "transferred to"', () {
      expect(
        SmsFieldExtractor.extractMerchant('transferred to FLIPKART'),
        'FLIPKART',
      );
    });

    test('extracts merchant after "via" keyword', () {
      expect(
        SmsFieldExtractor.extractMerchant('payment of Rs.500 via GOOGLE PAY'),
        'GOOGLE PAY',
      );
    });

    test('returns null when no merchant found', () {
      expect(
        SmsFieldExtractor.extractMerchant(
            'Rs.1500 debited from a/c XX1234 Avl Bal 5000'),
        isNull,
      );
    });

    test('returns null for empty body', () {
      expect(SmsFieldExtractor.extractMerchant(''), isNull);
    });

    // ── Real-world examples ────────────────────────────────────────────────

    test('extracts merchant from SBI SMS', () {
      expect(
        SmsFieldExtractor.extractMerchant(
            'Rs.1500 debited at AMAZON from a/c XX1234'),
        'AMAZON',
      );
    });

    test('extracts merchant from HDFC SMS', () {
      expect(
        SmsFieldExtractor.extractMerchant(
            'INR 500 spent at SWIGGY on Card XX5678'),
        'SWIGGY',
      );
    });
  });

  group('SmsFieldExtractor.extractBalance', () {
    test('extracts "Avl Bal" balance', () {
      expect(
        SmsFieldExtractor.extractBalance(
            'debited Rs.1500 Avl Bal Rs.12340'),
        closeTo(12340, 0.01),
      );
    });

    test('extracts "Bal" balance', () {
      expect(
        SmsFieldExtractor.extractBalance('Bal Rs. 25,000.50'),
        closeTo(25000.50, 0.01),
      );
    });

    test('extracts "Available Balance" balance', () {
      expect(
        SmsFieldExtractor.extractBalance(
            'Available Balance Rs. 50000'),
        closeTo(50000, 0.01),
      );
    });

    test('extracts "balance is" balance', () {
      expect(
        SmsFieldExtractor.extractBalance(
            'Your account balance is Rs. 12340'),
        closeTo(12340, 0.01),
      );
    });

    test('extracts balance without currency prefix', () {
      expect(
        SmsFieldExtractor.extractBalance('Avl Bal 5000'),
        closeTo(5000, 0.01),
      );
    });

    test('returns null when no balance found', () {
      expect(
        SmsFieldExtractor.extractBalance('Your OTP is 123456'),
        isNull,
      );
    });

    test('returns null for empty body', () {
      expect(SmsFieldExtractor.extractBalance(''), isNull);
    });
  });

  group('SmsFieldExtractor.extractReferenceNumber', () {
    // ── Ref prefix ─────────────────────────────────────────────────────────

    test('extracts "Ref" reference', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber(
            'Ref: ABC123XYZ of UPI transaction'),
        'ABC123XYZ',
      );
    });

    test('extracts "RefNo" reference (uppercase N)', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber(
            'RefNo 123ABC789 of transaction'),
        '123ABC789',
      );
    });

    test('extracts "Refno" reference (lowercase n)', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber('Refno ABC123456'),
        'ABC123456',
      );
    });

    test('extracts "Ref No" reference', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber(
            'Ref No XYZ789012 of debit'),
        'XYZ789012',
      );
    });

    test('extracts "Reference" keyword via keywordRef fallback', () {
      // "Reference ABC123XYZ" uses the keyword-based pattern (not prefixed ref)
      expect(
        SmsFieldExtractor.extractReferenceNumber(
            'Reference number ABC123XYZ of transaction'),
        'ABC123XYZ',
      );
    });

    // ── Txn prefix ─────────────────────────────────────────────────────────

    test('extracts "Txn" reference', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber('Txn ABC123456'),
        'ABC123456',
      );
    });

    test('extracts "Txn ID" reference', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber('Txn ID 123456789'),
        '123456789',
      );
    });

    test('extracts "Trxn" reference', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber('Trxn ABC123456'),
        'ABC123456',
      );
    });

    // ── UTR prefix ─────────────────────────────────────────────────────────

    test('extracts "UTR" reference', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber(
            'UTR 123456789012 of NEFT'),
        '123456789012',
      );
    });

    test('extracts "UTR No" reference', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber(
            'UTR No 9876543210'),
        '9876543210',
      );
    });

    test('extracts "UTR#" reference', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber('UTR# ABC123DEF'),
        'ABC123DEF',
      );
    });

    // ── Real-world examples ────────────────────────────────────────────────

    test('extracts reference from SBI SMS', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber(
            'Ref No 123456789012 - Rs.1500 debited from a/c XX1234'),
        '123456789012',
      );
    });

    test('extracts reference from HDFC SMS', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber(
            'Txn ID ABC123456 - INR 50000 credited'),
        'ABC123456',
      );
    });

    test('extracts reference from ICICI SMS', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber(
            'Ref: XYZ789012 - Rs.2500 spent at AMAZON'),
        'XYZ789012',
      );
    });

    test('extracts reference with "ref" lowercase keyword', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber(
            'ref: abc123456 - UPI transaction'),
        'abc123456',
      );
    });

    // ── Edge cases ─────────────────────────────────────────────────────────

    test('returns null when no reference found', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber(
            'Rs.1500 debited from a/c XX1234'),
        isNull,
      );
    });

    test('returns null for empty body', () {
      expect(SmsFieldExtractor.extractReferenceNumber(''), isNull);
    });

    test('ignores short alphanumeric sequences (< 6 chars)', () {
      expect(
        SmsFieldExtractor.extractReferenceNumber('Ref: ABC12'),
        isNull,
      );
    });
  });

  group('SmsFieldExtractor — Full Indian bank SMS parsing', () {
    // ── SBI SMS ────────────────────────────────────────────────────────────
    test('parses SBI debit SMS fully', () {
      const sms = 'Rs.1500 debited from a/c XX1234 at AMAZON on 15-03-2025 '
          'Ref No 123456789012 Avl Bal Rs.50000';
      expect(SmsFieldExtractor.extractAmount(sms), closeTo(1500, 0.01));
      expect(SmsFieldExtractor.extractMerchant(sms), 'AMAZON');
      expect(SmsFieldExtractor.extractBalance(sms), closeTo(50000, 0.01));
      expect(SmsFieldExtractor.extractReferenceNumber(sms), '123456789012');
    });

    // ── HDFC SMS ───────────────────────────────────────────────────────────
    test('parses HDFC credit SMS fully', () {
      const sms = 'INR 50000 credited to a/c XX5678 on 12-03-2025 '
          'Txn ID ABC123456 - Avl Bal Rs.75000';
      expect(SmsFieldExtractor.extractAmount(sms), closeTo(50000, 0.01));
      expect(SmsFieldExtractor.extractBalance(sms), closeTo(75000, 0.01));
      expect(SmsFieldExtractor.extractReferenceNumber(sms), 'ABC123456');
    });

    test('parses HDFC debit SMS fully', () {
      const sms = 'Rs.250 spent at SWIGGY on Card XX5678 '
          'Ref: XYZ789012 Avl Bal Rs.25000';
      expect(SmsFieldExtractor.extractAmount(sms), closeTo(250, 0.01));
      expect(SmsFieldExtractor.extractMerchant(sms), 'SWIGGY');
      expect(SmsFieldExtractor.extractBalance(sms), closeTo(25000, 0.01));
      expect(SmsFieldExtractor.extractReferenceNumber(sms), 'XYZ789012');
    });

    // ── ICICI SMS ──────────────────────────────────────────────────────────
    test('parses ICICI debit SMS fully', () {
      const sms = 'Rs.2500 spent at AMAZON on ICICI Bank Credit Card '
          'Ref: XYZ789012 Avl Bal 25000';
      expect(SmsFieldExtractor.extractAmount(sms), closeTo(2500, 0.01));
      expect(SmsFieldExtractor.extractMerchant(sms), 'AMAZON');
      expect(SmsFieldExtractor.extractBalance(sms), closeTo(25000, 0.01));
      expect(SmsFieldExtractor.extractReferenceNumber(sms), 'XYZ789012');
    });

    // ── Axis Bank SMS ──────────────────────────────────────────────────────
    test('parses Axis Bank debit SMS fully', () {
      const sms = 'A/C XX4321 debited by 1500 at POS - SWIGGY '
          'on 15-03-2025 - UTR 123456789012';
      expect(SmsFieldExtractor.extractAmount(sms), closeTo(1500, 0.01));
      expect(SmsFieldExtractor.extractMerchant(sms), 'SWIGGY');
      expect(SmsFieldExtractor.extractReferenceNumber(sms), '123456789012');
    });

    // ── Kotak Mahindra SMS ─────────────────────────────────────────────────
    test('parses Kotak UPI credit SMS fully', () {
      const sms = 'UPI transaction of Rs. 350 to GOOGLE PAY '
          'Ref: ABC123456 on 15-03-2025';
      expect(SmsFieldExtractor.extractAmount(sms), closeTo(350, 0.01));
      expect(SmsFieldExtractor.extractMerchant(sms), 'GOOGLE PAY');
      expect(SmsFieldExtractor.extractReferenceNumber(sms), 'ABC123456');
    });

    // ── PNB SMS ────────────────────────────────────────────────────────────
    test('parses PNB credit SMS fully', () {
      const sms = 'Rs.2000 credited to A/C XX7890 by NEFT '
          'UTR No 9876543210 on 20-03-2025 Avl Bal 15000';
      expect(SmsFieldExtractor.extractAmount(sms), closeTo(2000, 0.01));
      expect(SmsFieldExtractor.extractBalance(sms), closeTo(15000, 0.01));
      expect(SmsFieldExtractor.extractReferenceNumber(sms), '9876543210');
    });

    // ── Canara Bank SMS ────────────────────────────────────────────────────
    test('parses Canara Bank credit SMS fully', () {
      const sms = 'A/C XX3456 credited with 7500 on 20-03-2025 '
          'by NEFT Ref: ABC123XYZ Avl Bal 45000';
      expect(SmsFieldExtractor.extractAmount(sms), closeTo(7500, 0.01));
      expect(SmsFieldExtractor.extractBalance(sms), closeTo(45000, 0.01));
      expect(SmsFieldExtractor.extractReferenceNumber(sms), 'ABC123XYZ');
    });

    // ── Union Bank SMS ─────────────────────────────────────────────────────
    test('parses Union Bank debit SMS fully', () {
      const sms = 'debited by 1200 at SWIGGY from A/C XX9012 '
          'on 20-03-2025 Ref: ABC123456 Avl Bal 25000';
      expect(SmsFieldExtractor.extractAmount(sms), closeTo(1200, 0.01));
      expect(SmsFieldExtractor.extractMerchant(sms), 'SWIGGY');
      expect(SmsFieldExtractor.extractBalance(sms), closeTo(25000, 0.01));
      expect(SmsFieldExtractor.extractReferenceNumber(sms), 'ABC123456');
    });

    // ── Non-transaction SMS ────────────────────────────────────────────────
    test('returns null for non-transaction SMS', () {
      const sms = 'Your OTP for login is 123456. Do not share.';
      expect(SmsFieldExtractor.extractAmount(sms), isNull);
      expect(SmsFieldExtractor.extractMerchant(sms), isNull);
      expect(SmsFieldExtractor.extractBalance(sms), isNull);
      expect(SmsFieldExtractor.extractReferenceNumber(sms), isNull);
    });

    test('returns null for promotional SMS', () {
      const sms =
          'Get 20% off on all purchases at AMAZON this weekend!';
      expect(SmsFieldExtractor.extractAmount(sms), isNull);
      expect(SmsFieldExtractor.extractMerchant(sms),
          isNull); // "at AMAZON" but no transaction context
    });
  });
}
