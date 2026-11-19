import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A recovery code the user hasn't confirmed saving yet. It lives only in memory, never on disk:
/// after sign-up, a password reset or creating a new one, the app shows it once over everything.
final recoveryCodeToShowProvider =
    NotifierProvider<RecoveryCodeToShow, String?>(RecoveryCodeToShow.new);

class RecoveryCodeToShow extends Notifier<String?> {
  @override
  String? build() => null;

  void show(String? code) => state = code;

  void saved() => state = null;
}
