import 'package:fitplan_app/core/network/api_exception.dart';
import 'package:fitplan_app/features/auth/presentation/auth_messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('too many sign-in attempts get their own message', () {
    const error = ApiException(code: 'TooManyRequests', message: 'Too many requests.', statusCode: 429);

    expect(authErrorMessage(error), 'Too many attempts. Wait a minute and try again.');
  });
}
