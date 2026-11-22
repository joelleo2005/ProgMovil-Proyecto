import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';

import '../models/pet_report_model.dart';
import '../repositories/pet_report_repository.dart';
import '../utils/contact_helper.dart';

class PetProfileViewModel extends ChangeNotifier {
  /// [report] viene de Firestore. Si es null se muestran los datos de ejemplo.
  PetProfileViewModel({
    this.report,
    LatLng? userLocation,
    PetReportRepository? reportRepository,
  }) : _reportRepository = reportRepository ?? PetReportRepository() {
    final r = report;
    if (r == null) return;

    name = r.displayName;
    category = '${r.petTypeLabel} · ${r.isLost ? 'Mascota perdida' : 'Mascota encontrada'}';
    status = r.statusLabel;
    distance = userLocation == null
        ? '—'
        : _formatDistance(const Distance().as(LengthUnit.Meter, userLocation, r.position));
    tags = [
      if (r.date.isNotEmpty) r.date,
      if (r.time.isNotEmpty) r.time,
    ];
    description = r.description;
    features = {
      'Color': r.characteristics.isEmpty ? 'No especificado' : r.characteristics,
      'Tamaño': 'No especificado',
      'Edad': 'No especificado',
      'Señas': 'No especificado',
    };
    lastLocation =
        'Lat: ${r.latitude.toStringAsFixed(4)}, Lng: ${r.longitude.toStringAsFixed(4)}';
    imageUrl = r.imageUrl;
    position = r.position;
    ownerName = r.ownerName.isEmpty ? 'Usuario de LostPaws' : r.ownerName;
    ownerPhone = r.ownerPhone;
    ownerInitials = _initials(ownerName);
    publishInfo = r.createdAt == null
        ? 'Publicado recientemente'
        : 'Publicado ${_timeAgo(r.createdAt!)}';
  }

  final PetReportModel? report;
  final PetReportRepository _reportRepository;

  /// ¿El usuario actual es quien publicó el reporte?
  bool get isOwner =>
      report != null && report!.ownerId == FirebaseAuth.instance.currentUser?.uid;

  // Datos de la mascota (valores de ejemplo si no llega un reporte)
  String name = 'Rocky';
  String category = 'Perro · Golden Retriever · Macho';
  String status = 'Perdido';
  String distance = '0.3 km';

  List<String> tags = const [
    '31 ago 2026',
    '10:30 AM',
    'Collar rojo',
  ];

  String description =
      'Rocky se perdió cerca del parque Lincoln el lunes en la tarde. '
      'Tiene 3 años, es muy cariñoso y responde a su nombre. Lleva '
      'collar rojo con placa. Fue visto por última vez corriendo hacia la '
      'Av. Insurgentes.';

  Map<String, String> features = const {
    'Color': 'Dorado / Arena',
    'Tamaño': 'Grande (~30 kg)',
    'Edad': '3 años',
    'Señas': 'Cicatriz oreja der.',
  };

  String lastLocation = 'Av. Insurgentes, Lima · Hace 5 min';
  String imageUrl =
      'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=800&q=80';
  /// Punto del reporte para el mini mapa (por defecto, Centro de Lima).
  LatLng position = const LatLng(-12.046374, -77.042793);

  /// Texto libre de "Color / Características" del formulario.
  String get characteristics => report?.characteristics ?? (features['Color'] ?? '');

  // Datos del contacto
  String ownerInitials = 'MG';
  String ownerName = 'María Gonzalez';
  String ownerPhone = '+51 987 654 321';
  String publishInfo = 'Publicado hace 2 horas · 4 reportes';

  static String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'hace un momento';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} días';
  }

  void shareViaGmail(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abriendo Gmail...')),
    );
  }

  void shareViaEmail(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abriendo aplicación de correo...')),
    );
  }

  void shareViaSMS(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abriendo mensajes SMS...')),
    );
  }

  void shareViaWhatsApp(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abriendo WhatsApp...')),
    );
  }

  void onBackPressed(BuildContext context) {
    Navigator.maybePop(context);
  }

  Future<void> onContactOwner(BuildContext context) async {
    final phone = ownerPhone.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta publicación no tiene un número de contacto registrado.'),
        ),
      );
      return;
    }
    await ContactHelper.openPhoneDialer(phone);
  }


  Future<void> onMarkRescued(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (report == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('¡Mascota marcada como rescatada!')),
      );
      return;
    }
    if (!isOwner) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Solo quien publicó el reporte puede marcarlo como rescatado.')),
      );
      return;
    }
    try {
      await _reportRepository.markAsRescued(report!.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('¡Mascota marcada como rescatada!')),
      );
      navigator.maybePop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el reporte: $e')),
      );
    }
  }
}
