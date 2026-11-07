import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  bool get isLogin => _isLogin;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;

  void toggleAuthMode(bool isLoginMode) {
    if (_isLogin != isLoginMode) {
      _isLogin = isLoginMode;
      notifyListeners();
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Simulación de autenticación (retorna true si tuvo éxito)
  Future<bool> authenticate({
    required String email,
    required String password,
    String? name,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulación de respuesta de red o Firebase
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Simulación de login con Google
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    _isLoading = false;
    notifyListeners();
    return true;
  }
}