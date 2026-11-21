import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/user_model.dart';
import 'user_repository.dart';

/// Envuelve Firebase Authentication y mantiene sincronizado
/// el perfil del usuario en Firestore (`users/{uid}`).
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, UserRepository? userRepository})
      : _auth = auth ?? FirebaseAuth.instance,
        _userRepository = userRepository ?? UserRepository();

  final FirebaseAuth _auth;
  final UserRepository _userRepository;

  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Inicio de sesión con correo y contraseña.
  Future<User> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    // Por si la cuenta se creó desde la consola y no tiene perfil aún.
    await _userRepository.createUserIfMissing(
      UserModel(uid: user.uid, name: user.displayName ?? '', email: email),
    );
    return user;
  }

  /// Registro con correo y contraseña + creación del perfil en Firestore.
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name);
    await _userRepository.createUser(
      UserModel(uid: user.uid, name: name, email: email),
    );
    return user;
  }

  /// Inicio de sesión con Google (proveedor OAuth de Firebase Auth).
  /// Requiere habilitar "Google" en la consola y registrar la huella SHA-1.
  Future<User> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    final cred = kIsWeb
        ? await _auth.signInWithPopup(provider)
        : await _auth.signInWithProvider(provider);
    final user = cred.user!;
    await _userRepository.createUserIfMissing(
      UserModel(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        avatarUrl: user.photoURL ?? UserModel.defaultAvatarUrl,
      ),
    );
    return user;
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();

  /// Traduce los códigos de error de Firebase Auth a mensajes en español.
  static String messageFor(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'El correo no es válido.';
        case 'user-disabled':
          return 'Esta cuenta fue deshabilitada.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Correo o contraseña incorrectos.';
        case 'email-already-in-use':
          return 'Ya existe una cuenta con ese correo.';
        case 'weak-password':
          return 'La contraseña es muy débil (mínimo 6 caracteres).';
        case 'operation-not-allowed':
          return 'Este método de acceso no está habilitado en Firebase.';
        case 'network-request-failed':
          return 'Sin conexión a internet.';
        case 'too-many-requests':
          return 'Demasiados intentos. Inténtalo más tarde.';
        case 'web-context-canceled':
        case 'canceled':
          return 'Inicio de sesión cancelado.';
      }
      return error.message ?? 'Error de autenticación (${error.code}).';
    }
    return 'Ocurrió un error inesperado.';
  }
}
