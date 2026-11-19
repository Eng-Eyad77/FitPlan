import '../../../core/network/api_exception.dart';

/// Turns an API error into the sentence we show on the auth screens.
String authErrorMessage(ApiException error) => switch (error.code) {
      'InvalidCredentials' => 'Wrong username or password.',
      ApiException.usernameAlreadyExists => 'This username is already taken. Try another one.',
      'TooManyRequests' => 'Too many attempts. Wait a minute and try again.',
      'InvalidRecoveryCode' => 'The username or recovery code is wrong.',
      'ValidationFailed' => error.fieldErrors.values.firstOrNull?.firstOrNull ?? error.message,
      _ when error.isTemporary => error.message,
      _ => 'Something went wrong. Please try again.',
    };
