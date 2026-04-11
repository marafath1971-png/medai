import 'package:flutter/foundation.dart';
import '../../../models/user.dart';
import '../../../services/auth/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _state = AuthState.loading;
    notifyListeners();

    final success = await _authService.tryAutoLogin();
    if (success) {
      _user = _authService.currentUser;
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );

    if (result['success'] == true) {
      _user = _authService.currentUser;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email: email, password: password);

    if (result['success'] == true) {
      _user = _authService.currentUser;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle(String idToken) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.loginWithGoogle(idToken);

    if (result['success'] == true) {
      _user = _authService.currentUser;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithApple(String idToken) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.loginWithApple(idToken);

    if (result['success'] == true) {
      _user = _authService.currentUser;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _state = AuthState.loading;
    notifyListeners();

    final result = await _authService.forgotPassword(email);

    _state = result['success'] == true
        ? AuthState.unauthenticated
        : AuthState.error;
    _errorMessage = result['message'];
    notifyListeners();

    return result['success'] == true;
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _state = AuthState.loading;
    notifyListeners();

    final result = await _authService.resetPassword(
      token: token,
      newPassword: newPassword,
    );

    if (result['success'] == true) {
      _state = AuthState.unauthenticated;
    } else {
      _errorMessage = result['message'];
      _state = AuthState.error;
    }
    notifyListeners();

    return result['success'] == true;
  }

  Future<bool> verifyEmail(String token) async {
    _state = AuthState.loading;
    notifyListeners();

    final result = await _authService.verifyEmail(token);

    if (result['success'] == true) {
      _user = _user?.copyWith(emailVerified: true);
    }
    _state = result['success'] == true
        ? AuthState.authenticated
        : AuthState.error;
    _errorMessage = result['message'];
    notifyListeners();

    return result['success'] == true;
  }

  Future<Map<String, dynamic>?> enable2FA() async {
    return await _authService.enable2FA();
  }

  Future<bool> verify2FA(String code) async {
    final result = await _authService.verify2FA(code);
    if (result['success'] == true) {
      _user = _user?.copyWith(twoFactorEnabled: true);
      notifyListeners();
    }
    return result['success'] == true;
  }

  Future<bool> disable2FA(String code) async {
    final result = await _authService.disable2FA(code);
    if (result['success'] == true) {
      _user = _user?.copyWith(twoFactorEnabled: false);
      notifyListeners();
    }
    return result['success'] == true;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _user != null
          ? AuthState.authenticated
          : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  void refreshUser() {
    _user = _authService.currentUser;
    notifyListeners();
  }
}
