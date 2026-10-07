import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLogin = true;
  bool _obscurePassword = true;

  bool get isLogin => _isLogin;
  bool get obscurePassword => _obscurePassword;

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

  // Simulación de autenticación
  Future<void> authenticate(BuildContext context) async {
    // Aquí va la lógica real de Firebase u otra API
    await Future.delayed(const Duration(seconds: 1));
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}