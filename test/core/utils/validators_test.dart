import 'package:connectme_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.fullName', () {
    test('rejects an empty name', () {
      expect(Validators.fullName(''), isNotNull);
    });

    test('rejects a name shorter than 3 characters', () {
      expect(Validators.fullName('Al'), isNotNull);
    });

    test('rejects a name that does not start with a capital letter', () {
      expect(Validators.fullName('bruno pham'), isNotNull);
    });

    test('accepts a properly capitalised name', () {
      expect(Validators.fullName('Bruno Pham'), isNull);
    });
  });

  group('Validators.email', () {
    test('rejects an email without an @ symbol', () {
      expect(Validators.email('bruno.example.com'), isNotNull);
    });

    test('rejects an empty email', () {
      expect(Validators.email(''), isNotNull);
    });

    test('accepts a valid email', () {
      expect(Validators.email('bruno@connectme.app'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects a password shorter than 6 characters', () {
      expect(Validators.password('Ab1'), isNotNull);
    });

    test('rejects a password without a digit', () {
      expect(Validators.password('abcdef'), isNotNull);
    });

    test('accepts a 6+ character password with a letter and a digit', () {
      expect(Validators.password('secret123'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('fails when the confirmation does not match', () {
      expect(Validators.confirmPassword('other123', 'secret123'), isNotNull);
    });

    test('passes when the confirmation matches', () {
      expect(Validators.confirmPassword('secret123', 'secret123'), isNull);
    });
  });

  group('Validators.postContent', () {
    test('rejects empty content', () {
      expect(Validators.postContent('   ', maxLength: 280), isNotNull);
    });

    test('rejects content longer than the limit', () {
      final String tooLong = 'a' * 300;
      expect(Validators.postContent(tooLong, maxLength: 280), isNotNull);
    });

    test('accepts valid content', () {
      expect(Validators.postContent('hello world', maxLength: 280), isNull);
    });
  });

  group('Validators.donationAmount', () {
    test('rejects a non numeric amount', () {
      expect(Validators.donationAmount('abc', min: 1, max: 5000), isNotNull);
    });

    test('rejects an amount below the minimum', () {
      expect(Validators.donationAmount('0.5', min: 1, max: 5000), isNotNull);
    });

    test('rejects an amount above the maximum', () {
      expect(Validators.donationAmount('6000', min: 1, max: 5000), isNotNull);
    });

    test('accepts an amount inside the range', () {
      expect(Validators.donationAmount('25', min: 1, max: 5000), isNull);
    });
  });
}
