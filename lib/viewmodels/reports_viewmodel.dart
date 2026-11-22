import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/pet_report_model.dart';
import '../repositories/pet_report_repository.dart';

// El modelo de los reportes ahora está en models/pet_report_model.dart
typedef MyReport = PetReportModel;

class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel({PetReportRepository? reportRepository})
      : _reportRepository = reportRepository ?? PetReportRepository() {
    _listenMyReports();
  }

  final PetReportRepository _reportRepository;
  StreamSubscription<List<PetReportModel>>? _sub;

  // Reportes activos del usuario actual, sincronizados con Firestore
  List<MyReport> myReports = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  void _listenMyReports() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _isLoading = false;
      return;
    }
    _sub = _reportRepository.watchUserReports(uid).listen(
      (reports) {
        myReports = reports.where((r) => r.isActive).toList();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error leyendo mis reportes: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Texto de estado que se muestra en la tarjeta.
  String statusText(MyReport report) =>
      report.isLost ? 'Perdido' : 'Encontrado por usted';

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // Acciones de los botones
  /// Abre el formulario en modo edición. Al guardar, la lista se actualiza
  /// sola porque escucha a Firestore en tiempo real.
  void onEditPressed(BuildContext context, MyReport report) {
    Navigator.pushNamed(context, '/create_report', arguments: report);
  }

  // Nueva función para confirmar rescate con diálogo en dos pasos
  void onConfirmRescuePressed(
      BuildContext context,
      MyReport report,
      Future<bool?> Function(BuildContext, MyReport) showConfirmDialog,
      VoidCallback showSuccessDialog,
      ) async {
    // 1. Mostramos el modal marrón pidiendo confirmación
    final bool? confirmed = await showConfirmDialog(context, report);

    // 2. Si el usuario presionó "Confirmar rescate" (confirmed == true)
    if (confirmed == true) {
      try {
        // Marcamos el reporte como rescatado en Firestore: desaparece del mapa
        // y de esta lista (el stream se actualiza solo).
        await _reportRepository.markAsRescued(report.id);
        // 3. Mostramos el modal de éxito (check verde)
        showSuccessDialog();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo confirmar el rescate: $e')),
          );
        }
      }
    }
  }
}
