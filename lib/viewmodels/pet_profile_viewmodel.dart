import 'package:flutter/material.dart';

import '../models/report.dart';
import '../repositories/report_repository.dart';

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

  String get dateLabel => report == null ? '' : formatDate(report!.date);
  String get timeLabel => report == null ? '' : formatTime(report!.date);
  String get publishedLabel => report == null ? '' : 'Publicado ${timeAgo(report!.createdAt)}';

  String get coordinatesLabel {
    final r = report;
    if (r == null) return '';
    return '${r.location.latitude.toStringAsFixed(4)}, ${r.location.longitude.toStringAsFixed(4)}';
  }

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

  // ---- Formato de fechas (sin paquetes extra) ----

  static const _months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  /// Ej. "31 ago 2026"
  static String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// Ej. "10:30 AM"
  static String formatTime(DateTime d) {
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minutes = d.minute.toString().padLeft(2, '0');
    final period = d.hour < 12 ? 'AM' : 'PM';
    return '$hour12:$minutes $period';
  }

  /// Ej. "hace 5 min", "hace 2 h", "hace 3 días"
  static String timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'hace un momento';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'hace 1 día';
    return 'hace ${diff.inDays} días';
  }

  void _onRepositoryChanged() => notifyListeners();

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}
