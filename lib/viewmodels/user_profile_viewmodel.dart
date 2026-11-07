import 'package:flutter/material.dart';

class UserProfileViewModel extends ChangeNotifier {
  String _name = 'Alexandro de la Vega';
  String _email = 'alexandro.vega@lostpaws.pe';
  String _phone = '+51 987 654 321';
  String _location = 'Miraflores, Lima';
  String _avatarUrl =
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80';

  int _activeReports = 2;
  int _rescuedPets = 4;
  bool _notificationsEnabled = true;

  // Getters
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get location => _location;
  String get avatarUrl => _avatarUrl;
  int get activeReports => _activeReports;
  int get rescuedPets => _rescuedPets;
  bool get notificationsEnabled => _notificationsEnabled;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String phone,
    required String location,
    required String avatarUrl,
  }) {
    _name = name.trim();
    _phone = phone.trim();
    _location = location.trim();
    _avatarUrl = avatarUrl.trim();
    notifyListeners();
  }

  void onLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tendrás que volver a ingresar tus credenciales.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF906A55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              // Cuando conectemos auth_screen, reemplazará la ruta actual:
              // Navigator.pushReplacementNamed(context, '/auth');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sesión cerrada.')),
              );
            },
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}