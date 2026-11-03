import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/domain/auth_session.dart';

final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => SessionStorage(const FlutterSecureStorage()),
);

/// Keeps the logged-in session (user + JWT) encrypted on the device:
/// Keychain on iOS, Keystore on Android, WebCrypto on the web.
class SessionStorage {
  SessionStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'fitplan.session';

  Future<AuthSession?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      return AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // corrupted or from an older app version: start logged out
      await clear();
      return null;
    }
  }

  Future<void> save(AuthSession session) =>
      _storage.write(key: _key, value: jsonEncode(session.toJson()));

  Future<void> clear() => _storage.delete(key: _key);
}
