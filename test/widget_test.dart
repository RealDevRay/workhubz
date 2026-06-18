import 'package:flutter_test/flutter_test.dart';
import 'package:workhubz/core/utils/currency_formatter.dart';
import 'package:workhubz/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('accepts valid Kenyan phone number', () {
      expect(Validators.validatePhoneNumber('0712345678'), isNull);
      expect(Validators.validatePhoneNumber('+254712345678'), isNull);
    });

    test('rejects invalid Kenyan phone number', () {
      expect(
        Validators.validatePhoneNumber('12345'),
        'Invalid Kenyan phone number format',
      );
    });
  });

  group('CurrencyFormatter', () {
    test('parses KES values', () {
      expect(CurrencyFormatter.parseKes('KSh 12,500'), 12500);
    });

    test('formats compact values', () {
      expect(CurrencyFormatter.formatCompact(1500), 'KSh 1.5K');
      expect(CurrencyFormatter.formatCompact(2500000), 'KSh 2.5M');
    });
  });
}
