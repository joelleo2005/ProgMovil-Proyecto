import 'package:flutter/material.dart';

// Un modelo simple para los reportes
class MyReport {
  final String id;
  final String name;
  final String description;
  final String status;
  final String imageUrl;

  MyReport({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.imageUrl,
  });
}

class ReportsViewModel extends ChangeNotifier {
  // Datos simulados (mock data) basados en el diseño
  final List<MyReport> myReports = [
    MyReport(
      id: 'r1',
      name: 'Rufo',
      description: 'Perro blanco perdido en miraflores',
      status: 'Encontrado por usted',
      imageUrl: 'https://images.unsplash.com/photo-1544568100-847a948585b9?auto=format&fit=crop&w=200&q=80', // Un perro blanco
    ),
    MyReport(
      id: 'r2',
      name: 'Felix',
      description: 'Michi',
      status: 'Pérdido',
      imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=200&q=80', // Un gato
    ),
  ];

  // Acciones de los botones
  void onEditPressed(BuildContext context, MyReport report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editando reporte de ${report.name}...')),
    );
    // Aquí iría la navegación a la pantalla de edición
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
      // AQUÍ VA LA LÓGICA DE BACKEND:
      // - Llamada a la API para cambiar estado
      // - Eliminar el reporte de la lista local
      myReports.removeWhere((r) => r.id == report.id);
      notifyListeners(); // Actualiza la vista para que el reporte desaparezca

      // 3. Mostramos el modal de éxito (check verde)
      showSuccessDialog();
    }
  }
}