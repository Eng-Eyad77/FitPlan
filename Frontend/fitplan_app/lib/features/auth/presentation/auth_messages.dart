import '../../../core/network/api_exception.dart';

/// Turns an API error into the sentence we show on the auth screens.
String authErrorMessage(ApiException error) => switch (error.code) {
      'InvalidCredentials' => 'Wrong username or password.',
      'UsernameAlreadyExists' => 'This username is already taken. Try another one.',
      ApiException.networkError => error.message,
      'ValidationFailed' => error.fieldErrors.values.firstOrNull?.firstOrNull ?? error.message,
      _ => 'Something went wrong. Please try again.',
    };
