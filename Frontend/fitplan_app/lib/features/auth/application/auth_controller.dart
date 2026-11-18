import 'dart:async';

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
  Future<AuthSession?>? _renewing;

  @override
  Future<AuthSession?> build() async {
    final storage = ref.read(sessionStorageProvider);
    final saved = await storage.read();
    if (saved == null || !saved.isExpired) return saved;

    // The JWT lives 30 minutes. A session from an older app version has no way to renew it.
    final refreshToken = saved.refreshToken;
    if (refreshToken == null) {
      await storage.clear();
      return null;
    }

    try {
      final renewed = await ref.read(authRepositoryProvider).refresh(refreshToken);
      await storage.save(renewed);
      return renewed;
    } on ApiException catch (error) {
      if (_sessionEnded(error)) {
        await storage.clear();
        return null;
      }
      // offline or the server is waking: stay logged in, and renew on the first request
      return saved;
    }
  }

  /// Called when a request sent with [sentToken] got 401. Returns the session to retry with, or
  /// null when the user is now logged out. Throws ApiException when the server couldn't be reached,
  /// and the user stays logged in. Requests that fail together share one renewal.
  Future<AuthSession?> renewAfterUnauthorized(String sentToken) async {
    final current = state.value;
    if (current == null) return null;

    // another request already renewed it while this one was on its way
    if (current.accessToken != sentToken) return current;

    final refreshToken = current.refreshToken;
    if (refreshToken == null) {
      await logout();
      return null;
    }

    return _renewing ??= _renew(refreshToken).whenComplete(() => _renewing = null);
  }

  Future<AuthSession?> _renew(String refreshToken) async {
    try {
      final renewed = await ref.read(authRepositoryProvider).refresh(refreshToken);
      await _start(renewed);
      return renewed;
    } on ApiException catch (error) {
      if (!_sessionEnded(error)) rethrow;
      await _clear();
      return null;
    }
  }

  // The server refused the refresh token itself: expired, revoked or already used.
  static bool _sessionEnded(ApiException error) => error.statusCode == 401 || error.statusCode == 400;

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

  /// Logs out on this device at once, and tells the server so the refresh token stops working.
  /// The device never waits for the server: without a connection, logging out still works.
  Future<void> logout() async {
    final refreshToken = state.value?.refreshToken;
    await _clear();
    if (refreshToken != null) {
      unawaited(ref.read(authRepositoryProvider).logout(refreshToken).catchError((Object _) {}));
    }
  }

  Future<void> _clear() async {
    await ref.read(sessionStorageProvider).clear();
    state = const AsyncData(null);
  }

  Future<void> _start(AuthSession session) async {
    await ref.read(sessionStorageProvider).save(session);
    state = AsyncData(session);
  }
}
