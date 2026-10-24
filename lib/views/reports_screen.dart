import 'package:flutter/material.dart';
import '../viewmodels/reports_viewmodel.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final ReportsViewModel _viewModel;

  // Paleta de colores del diseño
  static const Color bgColor = Color(0xFFF4EFEB); // El fondo crema
  static const Color textColorDark = Color(0xFF332B25); // Marrón oscuro para títulos
  static const Color textColorLight = Color(0xFF8C98A4); // Gris azulado para descripción
  static const Color statusColorDark = Color(0xFF1E3A5F); // Azul marino para el estado
  static const Color btnEditColor = Color(0xFFAFAFAF); // Gris para el botón Editar
  static const Color btnRescueColor = Color(0xFFD4ED15); // Verde limón brillante
  static const Color modalBrown = Color(0xFF946B54); // Marrón del modal
  static const Color modalTextGray = Color(0xFF837B75); // Gris para texto del modal

  @override
  void initState() {
    super.initState();
    _viewModel = ReportsViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // SafeArea para evitar que se superponga con la barra de estado superior
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Título con ícono
              Row(
                children: [
                  const Icon(Icons.search, size: 32, color: textColorDark),
                  const SizedBox(width: 12),
                  Text(
                    'Mis reportes',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textColorDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Lista de reportes
              Expanded(
                child: ListView.separated(
                  itemCount: _viewModel.myReports.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final report = _viewModel.myReports[index];
                    return _buildReportCard(context, report);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, MyReport report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: Foto + Nombre + Descripción
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(report.imageUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColorDark, // Se ve azul oscuro en el diseño
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: textColorLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Fila inferior: Estado + Botones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  report.status,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: statusColorDark,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildSmallButton(
                    label: 'Editar',
                    bgColor: btnEditColor,
                    textColor: Colors.white,
                    onTap: () => _viewModel.onEditPressed(context, report),
                  ),
                  const SizedBox(width: 8),
                  _buildSmallButton(
                    label: 'Confirmar rescate',
                    bgColor: btnRescueColor,
                    textColor: textColorDark,
                    onTap: () => _viewModel.onConfirmRescuePressed(
                      context,
                      report,
                      _showConfirmationDialog, // Función del paso 1
                      () => _showSuccessDialog(context), // Función del paso 2
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // --- MODAL 1: Confirmación (Marrón) ---
  Future<bool?> _showConfirmationDialog(BuildContext context, MyReport report) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            decoration: BoxDecoration(
              color: modalBrown,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabecera marrón oscura
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    '¿Confirmar rescate?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Cuerpo blanco
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Al confirmar el rescate usted confirma que la mascota ha sido reunida con su dueño. Esto causará que la publicación sea eliminada.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: modalTextGray,
                      height: 1.4,
                    ),
                  ),
                ),
                // Botones Inferiores
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModalButton(
                        label: 'Cancelar',
                        bgColor: btnEditColor,
                        textColor: textColorDark,
                        onTap: () => Navigator.pop(dialogContext, false),
                      ),
                      const SizedBox(width: 16),
                      _buildModalButton(
                        label: 'Confirmar rescate',
                        bgColor: btnRescueColor,
                        textColor: textColorDark,
                        onTap: () => Navigator.pop(dialogContext, true),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // --- MODAL 2: Éxito (Check Verde) ---
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '¡Rescate Exitoso!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColorDark,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'La mascota ha sido marcada como rescatada y el reporte ha sido eliminado de la lista.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColorLight,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textColorDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Botón auxiliar para el modal marrón
  Widget _buildModalButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}