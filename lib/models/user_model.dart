import 'package:cloud_firestore/cloud_firestore.dart';

/// Perfil de un usuario de LostPaws.
/// Se guarda en Firestore en `users/{uid}` (uid = id de Firebase Auth).
class UserModel {
  static const String defaultAvatarUrl =
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80';

  final String uid;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String avatarUrl;
  final bool notificationsEnabled;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.location = '',
    this.avatarUrl = defaultAvatarUrl,
    this.notificationsEnabled = true,
    this.createdAt,
  });

  /// Iniciales para avatares de texto (ej. "María Gonzalez" -> "MG").
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel.fromMap(doc.id, doc.data() ?? const {});
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    final avatar = data['avatarUrl'] as String?;
    return UserModel(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      location: data['location'] as String? ?? '',
      avatarUrl: (avatar == null || avatar.isEmpty) ? defaultAvatarUrl : avatar,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Mapa para escribir en Firestore. `createdAt` lo pone el servidor.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'avatarUrl': avatarUrl,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? location,
    String? avatarUrl,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt,
    );
  }
}
