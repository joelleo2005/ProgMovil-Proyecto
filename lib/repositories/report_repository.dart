import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../models/report.dart';

/// Fuente única de los reportes de la app.
///
/// Se crea UNA sola vez en `main.dart` y todas las pantallas leen de aquí,
/// así un reporte creado en "Crear publicación" aparece en el mapa, en el
/// detalle y en "Mis reportes" sin pasar datos a mano entre pantallas.
///
/// Por ahora guarda los reportes en memoria. Cuando conectemos Firebase,
/// solo cambia el interior de estos métodos (llamando a un servicio de
/// Firestore); los ViewModels y las Views quedan igual.
class ReportRepository extends ChangeNotifier {
  /// Id provisional del usuario logueado, hasta conectar Firebase Auth.
  static const String demoCurrentUserId = 'usuario_demo';
  static const String demoCurrentUserName = 'Alexandro de la Vega';
  static const String demoCurrentUserPhone = '+51 987 654 321';

  final List<Report> _reports = [];

  /// Todos los reportes (activos y resueltos).
  List<Report> get reports => List.unmodifiable(_reports);

  /// Reportes que deben verse en el mapa.
  List<Report> get activeReports => _reports.where((r) => r.isActive).toList();

  Report? getById(String id) {
    for (final r in _reports) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<Report> reportsByOwner(String ownerId) =>
      _reports.where((r) => r.ownerId == ownerId).toList();

  /// Genera un id único para un reporte nuevo.
  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> addReport(Report report) async {
    _reports.insert(0, report);
    notifyListeners();
  }

  Future<void> updateReport(Report updated) async {
    final index = _reports.indexWhere((r) => r.id == updated.id);
    if (index == -1) return;
    _reports[index] = updated;
    notifyListeners();
  }

  Future<void> markResolved(String id) async {
    final report = getById(id);
    if (report == null) return;
    await updateReport(report.copyWith(status: ReportStatus.resuelto));
  }

  /// Datos de demostración alrededor de la ubicación del usuario, para que el
  /// mapa no se vea vacío mientras no hay backend. BORRAR al conectar Firebase.
  void seedDemoDataIfEmpty(LatLng center) {
    if (_reports.isNotEmpty) return;

    final now = DateTime.now();
    _reports.addAll([
      Report(
        id: 'demo_rocky',
        type: ReportType.perdida,
        petType: PetType.perro,
        name: 'Rocky',
        description:
            'Se perdió cerca del parque el lunes en la tarde. Tiene 3 años, '
            'es muy cariñoso y responde a su nombre.',
        characteristics: 'Golden Retriever, pelaje dorado, collar rojo con placa',
        imageUrl:
            'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=800&q=80',
        location: LatLng(center.latitude + 0.0015, center.longitude + 0.0015),
        date: now.subtract(const Duration(hours: 5)),
        createdAt: now.subtract(const Duration(hours: 5)),
        ownerId: 'maria_g',
        ownerName: 'María Gonzalez',
        ownerPhone: '+51 912 345 678',
      ),
      Report(
        id: 'demo_felix',
        type: ReportType.perdida,
        petType: PetType.gato,
        name: 'Felix',
        description: 'Michi atigrado, se escapó por la ventana.',
        characteristics: 'Atigrado gris, ojos verdes',
        imageUrl:
            'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
        location: LatLng(center.latitude - 0.0020, center.longitude + 0.0008),
        date: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
        ownerId: demoCurrentUserId,
        ownerName: demoCurrentUserName,
        ownerPhone: demoCurrentUserPhone,
      ),
      Report(
        id: 'demo_encontrado',
        type: ReportType.encontrada,
        petType: PetType.perro,
        description: 'Perro blanco encontrado deambulando, está conmigo.',
        characteristics: 'Blanco, tamaño mediano, sin collar',
        imageUrl:
            'https://images.unsplash.com/photo-1544568100-847a948585b9?auto=format&fit=crop&w=800&q=80',
        location: LatLng(center.latitude + 0.0008, center.longitude - 0.0022),
        date: now.subtract(const Duration(hours: 2)),
        createdAt: now.subtract(const Duration(hours: 2)),
        ownerId: 'carlos_r',
        ownerName: 'Carlos Ramírez',
        ownerPhone: '+51 934 111 222',
      ),
    ]);
    notifyListeners();
  }
}
