import '../../../core/network/api_exception.dart';
import '../../../l10n/l10n.dart';

/// Turns an API error into the sentence we show on the auth screens.
String authErrorMessage(ApiException error) => switch (error.code) {
      'InvalidCredentials' => l10n.authWrongLogin,
      ApiException.usernameAlreadyExists => l10n.authUsernameTaken,
      'TooManyRequests' => l10n.errTooManyRequests,
      'InvalidEmailCode' => l10n.errInvalidEmailCode,
      'EmailAlreadyExists' => l10n.errEmailAlreadyExists,
      'EmailNotRegistered' => l10n.errEmailNotRegistered,
      'TooManyEmails' => l10n.errTooManyEmails,
      'EmailNotSent' => l10n.errEmailNotSent,
      'ValidationFailed' when isArabic => l10n.errValidation,
      'ValidationFailed' => error.fieldErrors.values.firstOrNull?.firstOrNull ?? error.message,
      _ when error.isTemporary => error.message,
      _ => l10n.errGeneric,
    };
