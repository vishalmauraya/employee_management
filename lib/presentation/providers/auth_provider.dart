import 'package:flutter/foundation.dart';

import '../../core/utils/api_exception.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  AuthStatus status = AuthStatus.unknown;
  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  Future<void> checkAuthStatus() async {
    final hasToken = await _authRepository.hasToken();
    if (hasToken) {
      user = await _authRepository.getCurrentUser();
      status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } else {
      status = AuthStatus.unauthenticated;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    return _authenticate(() => _authRepository.login(email: email, password: password));
  }

  Future<bool> register(String name, String email, String password) async {
    return _authenticate(
      () => _authRepository.register(name: name, email: email, password: password),
    );
  }

  Future<bool> _authenticate(Future<UserModel> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await action();
      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'An unexpected error occurred';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
