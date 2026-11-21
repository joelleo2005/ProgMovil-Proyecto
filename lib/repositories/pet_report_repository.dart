import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/firestore_collections.dart';
import '../models/pet_report_model.dart';

/// Acceso a la colección `pet_reports` de Cloud Firestore
/// (mascotas perdidas y encontradas).
///
/// Las consultas usan solo filtros de igualdad y se ordenan en el cliente,
/// así no hace falta crear índices compuestos en la consola.
class PetReportRepository {
  PetReportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection(FirestoreCollections.petReports);

  /// Publica un reporte nuevo y devuelve su id.
  Future<String> createReport(PetReportModel report) async {
    final ref = await _reports.add({
      ...report.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Reportes activos de todos los usuarios (para el mapa), en tiempo real.
  Stream<List<PetReportModel>> watchActiveReports() {
    return _reports
        .where('status', isEqualTo: ReportStatus.activo.name)
        .snapshots()
        .map(_toSortedList);
  }

  /// Reportes de un usuario (para "Mis reportes" y las métricas del perfil).
  Stream<List<PetReportModel>> watchUserReports(String uid) {
    return _reports
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map(_toSortedList);
  }

  Future<PetReportModel?> getReport(String id) async {
    final doc = await _reports.doc(id).get();
    if (!doc.exists) return null;
    return PetReportModel.fromFirestore(doc);
  }

  Future<void> updateReport(String id, Map<String, dynamic> fields) {
    return _reports.doc(id).update(fields);
  }

  /// Marca la mascota como rescatada: deja de aparecer en el mapa y en
  /// "Mis reportes", pero se conserva para el contador de "Reunidas".
  Future<void> markAsRescued(String id) {
    return updateReport(id, {
      'status': ReportStatus.rescatado.name,
      'rescuedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteReport(String id) => _reports.doc(id).delete();

  List<PetReportModel> _toSortedList(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final list = snapshot.docs.map(PetReportModel.fromFirestore).toList();
    // Más recientes primero (createdAt es null mientras el servidor lo asigna).
    list.sort((a, b) {
      final ad = a.createdAt ?? DateTime.now();
      final bd = b.createdAt ?? DateTime.now();
      return bd.compareTo(ad);
    });
    return list;
  }
}
