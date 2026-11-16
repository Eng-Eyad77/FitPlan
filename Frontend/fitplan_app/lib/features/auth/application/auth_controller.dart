import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
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

  /// Sign-up is never repeated by itself. If its answer is lost (timeout), the server may still
  /// have created the account, and a second tap would get "username taken". In both cases we try
  /// to log in with the same details: if that works, the account is the user's and we continue.
  Future<void> register(String username, String password) async {
    final repository = ref.read(authRepositoryProvider);
    AuthSession session;
    try {
      session = await repository.register(username: username, password: password);
    } on ApiException catch (error) {
      if (!_mayAlreadyExist(error)) rethrow;
      session = await _loginInstead(repository, username, password, error);
    }
    await _start(session);
  }

  static bool _mayAlreadyExist(ApiException error) =>
      error.code == ApiException.timeout || error.code == ApiException.usernameAlreadyExists;

  Future<AuthSession> _loginInstead(
    AuthRepository repository,
    String username,
    String password,
    ApiException registerError,
  ) async {
    try {
      return await repository.login(username: username, password: password);
    } on ApiException {
      // not this user's account, or still no answer: report what sign-up said
      throw registerError;
    }
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
