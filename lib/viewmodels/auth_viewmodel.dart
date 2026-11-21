import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLogin => _isLogin;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void toggleAuthMode(bool isLoginMode) {
    if (_isLogin != isLoginMode) {
      _isLogin = isLoginMode;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Autenticación con Firebase Auth (retorna true si tuvo éxito).
  // Si hay error, queda disponible en [errorMessage].
  Future<bool> authenticate({
    required String email,
    required String password,
    String? name,
  }) {
    return _run(() async {
      if (_isLogin) {
        await _authRepository.signIn(email: email, password: password);
      } else {
        await _authRepository.register(
          name: name ?? '',
          email: email,
          password: password,
        );
      }
    });
  }

  // Login con Google mediante Firebase Auth
  Future<bool> loginWithGoogle() {
    return _run(_authRepository.signInWithGoogle);
  }

  // Envía el correo de recuperación de contraseña
  Future<bool> sendPasswordReset(String email) {
    return _run(() => _authRepository.sendPasswordReset(email));
  }

  Future<void> logout() => _authRepository.signOut();

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      _errorMessage = AuthRepository.messageFor(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
