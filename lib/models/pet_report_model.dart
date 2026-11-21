import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

/// ¿La mascota se perdió o fue encontrada?
enum ReportType { perdida, encontrada }

/// Especie de la mascota.
enum PetType { perro, gato, otro }

/// Estado del reporte: activo (visible en el mapa) o rescatado (cerrado).
enum ReportStatus { activo, rescatado }

/// Reporte de una mascota perdida o encontrada.
/// Se guarda en Firestore en `pet_reports/{id}`.
class PetReportModel {
  final String id;

  // Quién publicó el reporte (copiamos nombre/teléfono para no tener que
  // leer el perfil del dueño cada vez que se abre el reporte).
  final String ownerId;
  final String ownerName;
  final String ownerPhone;

  final ReportType reportType;
  final PetType petType;
  final ReportStatus status;

  final String name;
  final String description;
  final String characteristics;
  final String imageUrl;

  final double latitude;
  final double longitude;

  // Fecha y hora en que se vio a la mascota, tal como las escribió el usuario.
  final String date;
  final String time;

  final DateTime? createdAt;

  const PetReportModel({
    this.id = '',
    required this.ownerId,
    required this.ownerName,
    this.ownerPhone = '',
    required this.reportType,
    required this.petType,
    this.status = ReportStatus.activo,
    required this.name,
    required this.description,
    required this.characteristics,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.time,
    this.createdAt,
  });

  // ---------- Helpers para la UI ----------

  LatLng get position => LatLng(latitude, longitude);
  bool get isLost => reportType == ReportType.perdida;
  bool get isActive => status == ReportStatus.activo;

  String get displayName => name.trim().isEmpty ? 'Sin nombre' : name;

  String get petTypeLabel {
    switch (petType) {
      case PetType.perro:
        return 'Perro';
      case PetType.gato:
        return 'Gato';
      case PetType.otro:
        return 'Otro';
    }
  }

  String get statusLabel {
    if (status == ReportStatus.rescatado) return 'Rescatado';
    return isLost ? 'Perdido' : 'Encontrado';
  }

  /// Imagen por defecto según la especie (mientras no haya subida de fotos).
  static String defaultImageFor(PetType type) {
    switch (type) {
      case PetType.perro:
        return 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80';
      case PetType.gato:
        return 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80';
      case PetType.otro:
        return 'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?auto=format&fit=crop&w=800&q=80';
    }
  }

  // ---------- Serialización Firestore ----------

  factory PetReportModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final petType = _enumFromName(PetType.values, data['petType'], PetType.otro);
    final image = data['imageUrl'] as String?;
    return PetReportModel(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      ownerPhone: data['ownerPhone'] as String? ?? '',
      reportType: _enumFromName(
        ReportType.values,
        data['reportType'],
        ReportType.perdida,
      ),
      petType: petType,
      status: _enumFromName(
        ReportStatus.values,
        data['status'],
        ReportStatus.activo,
      ),
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      characteristics: data['characteristics'] as String? ?? '',
      imageUrl: (image == null || image.isEmpty) ? defaultImageFor(petType) : image,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      date: data['date'] as String? ?? '',
      time: data['time'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Mapa para escribir en Firestore. `createdAt` lo pone el servidor.
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'reportType': reportType.name,
      'petType': petType.name,
      'status': status.name,
      'name': name,
      'description': description,
      'characteristics': characteristics,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'date': date,
      'time': time,
    };
  }

  static T _enumFromName<T extends Enum>(
    List<T> values,
    Object? name,
    T fallback,
  ) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }
}
