import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/session_storage.dart';
import '../data/auth_repository.dart';
import '../domain/auth_session.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

/// The single source of truth for "who is logged in".
///
/// - loading      -> the app is starting and reading the saved session
/// - data(null)   -> logged out
/// - data(session)-> logged in
///
/// The router listens to it: logging in or out moves the user automatically.
class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final storage = ref.read(sessionStorageProvider);
    final saved = await storage.read();

    // the JWT lives 30 minutes; an expired one would only fail on the first request
    if (saved == null || saved.isExpired) {
      await storage.clear();
      return null;
    }
    return saved;
  }

  /// Throws ApiException (wrong password, network...) so the screen can show it.
  /// The state only changes on success: the login screen keeps its own loading spinner.
  Future<void> login(String username, String password) async {
    final session = await ref
        .read(authRepositoryProvider)
        .login(username: username, password: password);
    await _start(session);
  }

  Future<void> register(String username, String password) async {
    final session = await ref
        .read(authRepositoryProvider)
        .register(username: username, password: password);
    await _start(session);
  }

  Future<void> logout() async {
    await ref.read(sessionStorageProvider).clear();
    state = const AsyncData(null);
  }

  Future<void> _start(AuthSession session) async {
    await ref.read(sessionStorageProvider).save(session);
    state = AsyncData(session);
  }
}
