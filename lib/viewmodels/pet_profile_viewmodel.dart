import 'package:flutter/material.dart';

import '../models/report.dart';
import '../repositories/report_repository.dart';
import '../utils/formatters.dart';

/// ViewModel del detalle de un reporte.
///
/// No guarda una copia del reporte: lo lee del repositorio por su id, así si
/// el reporte cambia (p. ej. se marca como rescatado) la pantalla se actualiza.
class PetProfileViewModel extends ChangeNotifier {
  final ReportRepository _repository;
  final String reportId;

  PetProfileViewModel(this._repository, {required this.reportId}) {
    _repository.addListener(_onRepositoryChanged);
  }

  /// El reporte a mostrar, o null si ya no existe.
  Report? get report => _repository.getById(reportId);

  /// Si el usuario logueado es quien publicó el reporte
  /// (solo él puede editarlo o marcarlo como rescatado).
  bool get isOwner => report?.ownerId == ReportRepository.demoCurrentUserId;

  String get ownerInitials {
    final parts = (report?.ownerName ?? '').trim().split(RegExp(r'\s+'));
    final initials = parts.where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase());
    return initials.isEmpty ? '?' : initials.join();
  }

  String get dateLabel => report == null ? '' : Formatters.date(report!.date);
  String get timeLabel => report == null ? '' : Formatters.time(report!.date);
  String get publishedLabel => report == null ? '' : 'Publicado ${Formatters.timeAgo(report!.createdAt)}';

  String get coordinatesLabel {
    final r = report;
    if (r == null) return '';
    return '${r.location.latitude.toStringAsFixed(4)}, ${r.location.longitude.toStringAsFixed(4)}';
  }

  String get lastSeenLabel => report == null ? '' : Formatters.timeAgo(report!.date);

  Future<void> markRescued() async {
    await _repository.markResolved(reportId);
  }

  // ---- Acciones que se implementan en pasos siguientes ----

  void onContactOwner(BuildContext context) {
    final r = report;
    if (r == null) return;
    final phone = r.ownerPhone.isEmpty ? 'sin teléfono registrado' : r.ownerPhone;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contactar a ${r.ownerName}: $phone')),
    );
  }

  void onEditReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('La edición de reportes llega en un próximo paso.')),
    );
  }

  void shareVia(BuildContext context, String channel) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abriendo $channel...')),
    );
  }

  void _onRepositoryChanged() => notifyListeners();

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}
