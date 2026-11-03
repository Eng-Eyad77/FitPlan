import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

/// The logged-in user, exactly as the API returns it from /api/auth/login and /register:
/// { "id": "...", "username": "eyad", "accessToken": "eyJ..." }
@freezed
abstract class AuthSession with _$AuthSession {
  const AuthSession._();

  const factory AuthSession({
    required String id,
    required String username,
    required String accessToken,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);

  /// Reads the "exp" claim of the JWT. A token we cannot read counts as expired.
  bool get isExpired {
    try {
      final payload = accessToken.split('.')[1];
      final claims = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(payload))))
          as Map<String, dynamic>;
      final expiresAt = DateTime.fromMillisecondsSinceEpoch((claims['exp'] as int) * 1000, isUtc: true);
      return DateTime.now().toUtc().isAfter(expiresAt);
    } catch (_) {
      return true;
    }
  }
}
