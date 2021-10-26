import 'package:biodiversity/models/login_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Login Result Test', () {
    final result = LoginResult('testMessage');
    expect(result.message, equals('testMessage'),
        reason: 'Login Result Message not saved');
    expect(result.isEmailConfirmed, isTrue,
        reason: 'Default setting for emailConfirmed is not true');
    expect(result.isRegistered, isTrue,
        reason: 'Default setting for isRegistered is not true');
  });
}
