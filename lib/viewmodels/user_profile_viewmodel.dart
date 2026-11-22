import 'dart:async';

import 'package:flutter/material.dart';

import '../models/pet_report_model.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/pet_report_repository.dart';
import '../repositories/user_repository.dart';

class UserProfileViewModel extends ChangeNotifier {
  UserProfileViewModel({
    AuthRepository? authRepository,
    UserRepository? userRepository,
    PetReportRepository? reportRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _userRepository = userRepository ?? UserRepository(),
        _reportRepository = reportRepository ?? PetReportRepository() {
    _listenProfile();
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final PetReportRepository _reportRepository;
  StreamSubscription<UserModel?>? _userSub;
  StreamSubscription<List<PetReportModel>>? _reportsSub;

  String _name = '';
  String _email = '';
  String _phone = '';
  String _location = '';
  String _avatarUrl = UserModel.defaultAvatarUrl;

  int _activeReports = 0;
  int _rescuedPets = 0;
  bool _notificationsEnabled = true;

  String? get _uid => _authRepository.currentUser?.uid;

  // Escucha en tiempo real el documento users/{uid} y sus reportes
  void _listenProfile() {
    final uid = _uid;
    if (uid == null) return;
    _email = _authRepository.currentUser?.email ?? '';

    _userSub = _userRepository.watchUser(uid).listen((user) {
      if (user == null) return;
      _name = user.name;
      _email = user.email.isEmpty ? _email : user.email;
      _phone = user.phone;
      _location = user.location;
      _avatarUrl = user.avatarUrl;
      _notificationsEnabled = user.notificationsEnabled;
      notifyListeners();
    }, onError: (e) => debugPrint('Error leyendo perfil: $e'));

    _reportsSub = _reportRepository.watchUserReports(uid).listen((reports) {
      _activeReports = reports.where((r) => r.isActive).length;
      _rescuedPets = reports.where((r) => !r.isActive).length;
      notifyListeners();
    }, onError: (e) => debugPrint('Error leyendo métricas: $e'));
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _reportsSub?.cancel();
    super.dispose();
  }

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
    final uid = _uid;
    if (uid != null) {
      _userRepository.updateUser(uid, {'notificationsEnabled': value});
    }
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

    // Guardamos los cambios en Firestore (users/{uid})
    final uid = _uid;
    if (uid != null) {
      _userRepository.updateUser(uid, {
        'name': _name,
        'phone': _phone,
        'location': _location,
        'avatarUrl': _avatarUrl,
      });
    }
  }

  /// "Seguridad y contraseña": Firebase envía al correo del usuario un enlace
  /// para elegir una contraseña nueva (así nunca manejamos contraseñas aquí).
  void onChangePassword(BuildContext context) {
    final user = _authRepository.currentUser;
    final messenger = ScaffoldMessenger.of(context);
    if (user == null || (user.email ?? '').isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No hay un correo asociado a esta cuenta.')),
      );
      return;
    }

    // Quien entró con Google no tiene contraseña en LostPaws: la gestiona Google.
    final usesPassword = user.providerData.any((p) => p.providerId == 'password');
    if (!usesPassword) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Iniciaste sesión con Google: tu contraseña se cambia desde tu cuenta de Google.'),
        ),
      );
      return;
    }

    final email = user.email!;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cambiar contraseña'),
        content: Text(
          'Te enviaremos un enlace a $email para que elijas una contraseña nueva.',
        ),
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
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await _authRepository.sendPasswordReset(email);
                messenger.showSnackBar(
                  SnackBar(content: Text('Listo. Revisa tu correo $email (también en spam).')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text(AuthRepository.messageFor(e))),
                );
              }
            },
            child: const Text('Enviar enlace', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final navigator = Navigator.of(context, rootNavigator: true);
              final messenger = ScaffoldMessenger.of(context);
              await _authRepository.signOut();
              navigator.pushNamedAndRemoveUntil('/auth', (route) => false);
              messenger.showSnackBar(
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