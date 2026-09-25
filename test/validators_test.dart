// test/validators_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pro_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('valid email passes', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
    });

    test('invalid email fails', () {
      expect(Validators.validateEmail('invalid-email'), isNotNull);
    });

    test('password length check', () {
      expect(Validators.validatePassword('123'), isNotNull);
      expect(Validators.validatePassword('123456'), isNull);
    });

    test('name validation', () {
      expect(Validators.validateName('A'), isNotNull);
      expect(Validators.validateName('Ali'), isNull);
    });
  });
}
