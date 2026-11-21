import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../models/report.dart';
import '../repositories/report_repository.dart';
import '../viewmodels/map_viewmodel.dart';
import '../viewmodels/pet_profile_viewmodel.dart';

/// Detalle de un reporte. Recibe solo el id; los datos se leen del repositorio.
class PetProfileView extends StatelessWidget {
  final String reportId;
  const PetProfileView({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PetProfileViewModel(
        context.read<ReportRepository>(),
        reportId: reportId,
      ),
      child: const _PetProfileBody(),
    );
  }
}

class _PetProfileBody extends StatefulWidget {
  const _PetProfileBody();

  @override
  State<_PetProfileBody> createState() => _PetProfileViewState();
}

class _PetProfileViewState extends State<_PetProfileBody> {
  late PetProfileViewModel _viewModel;
  late Report _report;

  // Paleta de diseño
  static const Color primaryDark = Color(0xFF221915);
  static const Color textMuted = Color(0xFF8C827A);
  static const Color alertRed = Color(0xFFFF3B30);
  static const Color foundGreen = Color(0xFF34C759);
  static const Color resolvedGrey = Color(0xFF8E8E93);
  static const Color cardBorder = Color(0xFFECE7E2);

  // Nuevos colores para la sección de contacto
  static const Color actionBrown = Color(0xFF90654F);
  static const Color successGreen = Color(0xFF34C759);
  static const Color contactCardBg = Color(0xFFF4EFEB);

  @override
  Widget build(BuildContext context) {
    _viewModel = context.watch<PetProfileViewModel>();
    final report = _viewModel.report;

    // El reporte pudo ser eliminado mientras la pantalla estaba abierta.
    if (report == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Este reporte ya no está disponible.')),
      );
    }
    _report = report;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _report.displayName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _report.petTypeLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(label: _viewModel.dateLabel),
                      _InfoChip(label: _viewModel.timeLabel),
                    ],
                  ),
                  const SizedBox(height: 22),

                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _report.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Color(0xFF635A53),
                    ),
                  ),
                  const SizedBox(height: 22),

                  if (_report.characteristics.trim().isNotEmpty) ...[
                    const Text(
                      'Características',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: _FeatureCard(
                        title: 'Color / señas',
                        value: _report.characteristics,
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],

                  const Text(
                    'Última ubicación conocida',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildMapPreview(),

                  // --- Nueva sección inferior ---
                  const SizedBox(height: 22),
                  // Quien publicó no necesita contactarse a sí mismo;
                  // solo él puede editar o marcar como rescatado.
                  if (!_viewModel.isOwner) _buildContactCard(context),
                  if (_viewModel.isOwner && _report.isActive) _buildBottomActions(context),
                  if (!_report.isActive) _buildResolvedBanner(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: contactCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: actionBrown.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Tienes información?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: actionBrown,
                child: Text(
                  _viewModel.ownerInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _report.ownerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _viewModel.publishedLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _viewModel.onContactOwner(context),
              icon: const Icon(Icons.phone_in_talk_outlined, color: Colors.white, size: 20),
              label: const Text(
                'Contactar dueño',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: actionBrown,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _viewModel.onEditReport(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: textMuted),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Editar reporte',
              style: TextStyle(
                color: Color(0xFF6B5E55),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _confirmRescue(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: successGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Marcar rescatado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showShareMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Para que ocupe solo el espacio necesario
          children: [
            const Text(
              'Compartir ubicación mediante...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.mail, color: Color(0xFFEA4335)), // Rojo Google
              title: const Text('Gmail', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () => _viewModel.shareVia(sheetContext, 'Gmail'),
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined, color: textMuted),
              title: const Text('Otro correo', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () => _viewModel.shareVia(sheetContext, 'otro correo'),
            ),
            ListTile(
              leading: const Icon(Icons.sms, color: Color(0xFF007AFF)), // Azul SMS
              title: const Text('SMS', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () => _viewModel.shareVia(sheetContext, 'SMS'),
            ),
            ListTile(
              // Usamos un ícono de chat verde para simular WhatsApp (Material Icons no tiene el logo oficial)
              leading: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366)),
              title: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () => _viewModel.shareVia(sheetContext, 'WhatsApp'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 310,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(_report.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircularButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.maybePop(context),
              ),
              _buildCircularButton(
                icon: Icons.share_outlined,
                onTap: () => _showShareMenu(context),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: !_report.isActive
                  ? resolvedGrey
                  : (_report.isLost ? alertRed : foundGreen),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _report.isActive ? _report.typeLabel : 'Resuelto',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 14, color: Color(0xFF6B4F3B)),
                const SizedBox(width: 4),
                Text(
                  context.read<MapViewModel>().distanceLabel(_report),
                  style: const TextStyle(
                    color: Color(0xFF463A33),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: primaryDark),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Mini mapa no interactivo centrado en el reporte. Usa el mismo
          // TileLayer que el mapa principal (con userAgentPackageName), que es
          // lo que exige OpenStreetMap para no bloquear las imágenes.
          FlutterMap(
            options: MapOptions(
              initialCenter: _report.location,
              initialZoom: 16,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ulima.lostpaws',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _report.location,
                    width: 26,
                    height: 26,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_pin, size: 16, color: Color(0xFF6B4F3B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${_viewModel.coordinatesLabel} · ${_viewModel.lastSeenLabel}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3B302A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolvedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: foundGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: foundGreen),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Este caso ya fue resuelto. ¡La mascota volvió a casa!',
              style: TextStyle(fontWeight: FontWeight.w600, color: primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRescue(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Marcar como rescatado?'),
        content: const Text('El reporte dejará de aparecer en el mapa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: successGreen),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await _viewModel.markRescued();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Mascota marcada como rescatada!')),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6E645D),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String value;

  const _FeatureCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECE7E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9E948C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E241E),
            ),
          ),
        ],
      ),
    );
  }
}