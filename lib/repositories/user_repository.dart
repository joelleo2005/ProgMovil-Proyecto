import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/firestore_collections.dart';
import '../models/user_model.dart';

/// Acceso a la colección `users` de Cloud Firestore.
class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  /// Crea el documento del usuario (se llama al registrarse).
  Future<void> createUser(UserModel user) {
    return _users.doc(user.uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Crea el documento solo si todavía no existe
  /// (útil para inicios de sesión con Google o cuentas creadas en la consola).
  Future<void> createUserIfMissing(UserModel user) async {
    final doc = await _users.doc(user.uid).get();
    if (!doc.exists) await createUser(user);
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Escucha en tiempo real los cambios del perfil.
  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => doc.exists ? UserModel.fromFirestore(doc) : null,
        );
  }

  /// Actualiza solo los campos indicados.
  Future<void> updateUser(String uid, Map<String, dynamic> fields) {
    return _users.doc(uid).set(fields, SetOptions(merge: true));
  }
}
