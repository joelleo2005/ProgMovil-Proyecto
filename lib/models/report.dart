import 'package:latlong2/latlong.dart';

/// Tipo de reporte: mascota perdida o mascota encontrada.
enum ReportType { perdida, encontrada }

/// Tipo de mascota, usado para el formulario y para los filtros del mapa.
enum PetType { perro, gato, otro }

/// Estado del reporte: activo (aparece en el mapa) o resuelto (ya se reencontró).
enum ReportStatus { activo, resuelto }

/// Modelo único de reporte que comparten todas las pantallas
/// (mapa, crear publicación, detalle, mis reportes).
///
/// Cuando conectemos Firebase, este mismo modelo tendrá un `fromMap` / `toMap`
/// para leer y escribir en Firestore; las pantallas no tendrán que cambiar.
class Report {
  final String id;
  final ReportType type;
  final PetType petType;

  /// Nombre de la mascota (puede no saberse si es una mascota encontrada).
  final String? name;
  final String description;
  final String characteristics;

  /// Foto de la mascota. Por ahora es una URL; cuando tengamos cámara puede
  /// ser también la ruta de un archivo local.
  final String imageUrl;

  /// Ubicación donde se perdió o se vio la mascota.
  final LatLng location;

  /// Fecha y hora del suceso (no de la publicación).
  final DateTime date;

  /// Datos del publicador, para el detalle y para "Mis reportes".
  final String ownerId;
  final String ownerName;
  final String ownerPhone;

  final ReportStatus status;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.type,
    required this.petType,
    this.name,
    required this.description,
    this.characteristics = '',
    required this.imageUrl,
    required this.location,
    required this.date,
    required this.ownerId,
    required this.ownerName,
    this.ownerPhone = '',
    this.status = ReportStatus.activo,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isLost => type == ReportType.perdida;
  bool get isActive => status == ReportStatus.activo;

  /// Nombre a mostrar en la UI aunque no se conozca el nombre real.
  String get displayName {
    if (name != null && name!.trim().isNotEmpty) return name!.trim();
    return isLost ? 'Mascota perdida' : 'Mascota encontrada';
  }

  String get typeLabel => isLost ? 'Perdido' : 'Encontrado';

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

  /// Crea una copia cambiando solo los campos indicados
  /// (útil para editar o marcar como resuelto).
  Report copyWith({
    ReportType? type,
    PetType? petType,
    String? name,
    String? description,
    String? characteristics,
    String? imageUrl,
    LatLng? location,
    DateTime? date,
    String? ownerName,
    String? ownerPhone,
    ReportStatus? status,
  }) {
    return Report(
      id: id,
      type: type ?? this.type,
      petType: petType ?? this.petType,
      name: name ?? this.name,
      description: description ?? this.description,
      characteristics: characteristics ?? this.characteristics,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      date: date ?? this.date,
      ownerId: ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
