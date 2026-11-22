import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../models/pet_report_model.dart';
import '../repositories/pet_report_repository.dart';
import '../utils/contact_helper.dart';
import '../utils/pet_image_helper.dart';
import '../viewmodels/map_viewmodel.dart';
import '../viewmodels/pet_profile_viewmodel.dart';

class PetProfileView extends StatefulWidget {
  /// Reporte de Firestore a mostrar (si es null se muestran datos de ejemplo).
  final PetReportModel? report;

  const PetProfileView({super.key, this.report});

  @override
  State<PetProfileView> createState() => _PetProfileViewState();
}

class _PetProfileViewState extends State<PetProfileView> {
  late PetProfileViewModel _viewModel;

  // Paleta de diseño
  static const Color primaryDark = Color(0xFF221915);
  static const Color textMuted = Color(0xFF8C827A);
  static const Color alertRed = Color(0xFFFF3B30);
  static const Color cardBorder = Color(0xFFECE7E2);

  // Nuevos colores para la sección de contacto
  static const Color actionBrown = Color(0xFF90654F);
  static const Color successGreen = Color(0xFF34C759);
  static const Color contactCardBg = Color(0xFFF4EFEB);

  @override
  void initState() {
    super.initState();
    _viewModel = PetProfileViewModel(
      report: widget.report,
      userLocation: context.read<MapViewModel>().userLocation,
    );
  }

  /// Abre "Editar reporte" y, si se guardaron cambios, vuelve a leer el
  /// reporte de Firestore para mostrar los datos actualizados.
  Future<void> _openEdit() async {
    final report = _viewModel.report;
    if (report == null) return;

    final saved = await Navigator.pushNamed(context, '/create_report', arguments: report);
    if (saved == null || !mounted) return;

    final updated = await PetReportRepository().getReport(report.id);
    if (updated == null || !mounted) return;
    setState(() {
      _viewModel = PetProfileViewModel(
        report: updated,
        userLocation: context.read<MapViewModel>().userLocation,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    _viewModel.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _viewModel.category,
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
                    children: _viewModel.tags
                        .map((tag) => _InfoChip(label: tag))
                        .toList(),
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
                    _viewModel.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Color(0xFF635A53),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // El formulario solo tiene un campo "Color / Características",
                  // así que mostramos una sola tarjeta (y solo si tiene texto).
                  if (_viewModel.characteristics.trim().isNotEmpty) ...[
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
                        value: _viewModel.characteristics,
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
                  // Quien publicó no necesita contactarse a sí mismo, y solo
                  // él puede editar o marcar como rescatado.
                  if (!_viewModel.isOwner) _buildContactCard(context),
                  if (_viewModel.isOwner) _buildBottomActions(context),
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
                      _viewModel.ownerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _viewModel.publishInfo,
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
              onPressed: _showContactOptions,
              icon: const Icon(Icons.phone_in_talk_outlined, color: Colors.white, size: 20),
              label: const Text(
                'Contactar persona',
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

  /// Muestra una selección de apps para contactar al dueño:
  /// - Aplicación de teléfono (keypad prellenado sin llamar).
  /// - WhatsApp (abre nuevo chat si está instalado).
  Future<void> _showContactOptions() async {
    final messenger = ScaffoldMessenger.of(context);
    final phone = _viewModel.ownerPhone.trim();
    if (phone.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Esta publicación no tiene un número de contacto registrado.'),
        ),
      );
      return;
    }

    final isWhatsAppInstalled = await ContactHelper.isWhatsAppInstalled();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Contactar a ${_viewModel.ownerName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Número registrado: $phone',
                  style: const TextStyle(
                    fontSize: 13,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 20),
                // Opción 1: Aplicación de llamadas (teclado con número prellenado, sin llamar)
                _buildContactOptionTile(
                  icon: Icons.dialpad_outlined,
                  iconColor: actionBrown,
                  iconBgColor: actionBrown.withValues(alpha: 0.12),
                  title: 'Aplicación de teléfono',
                  subtitle: 'Abrir teclado con el número listo para llamar',
                  enabled: true,
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    final success = await ContactHelper.openPhoneDialer(phone);
                    if (!success) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo abrir la aplicación de llamadas.'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Opción 2: WhatsApp (abre nuevo chat si está instalado)
                _buildContactOptionTile(
                  icon: Icons.chat_bubble_outline,
                  iconColor: isWhatsAppInstalled ? const Color(0xFF25D366) : Colors.grey,
                  iconBgColor: isWhatsAppInstalled
                      ? const Color(0xFF25D366).withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.12),
                  title: isWhatsAppInstalled ? 'WhatsApp' : 'WhatsApp (No disponible)',
                  subtitle: isWhatsAppInstalled
                      ? 'Abrir nuevo chat con el número registrado'
                      : 'No está instalado en este dispositivo',
                  enabled: isWhatsAppInstalled,
                  badge: isWhatsAppInstalled ? null : 'No instalado',
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    if (!isWhatsAppInstalled) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('WhatsApp no está instalado en este dispositivo.'),
                        ),
                      );
                      return;
                    }
                    final success = await ContactHelper.openWhatsAppChat(phone);
                    if (!success) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo abrir WhatsApp.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactOptionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
    String? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFFBF9F6) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled ? cardBorder : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: enabled ? primaryDark : Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled ? textMuted : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: enabled ? textMuted : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _openEdit,
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
            onPressed: () => _viewModel.onMarkRescued(context),
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
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
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
                onTap: () => _viewModel.shareViaGmail(context),
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined, color: textMuted),
                title: const Text('Otro correo', style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () => _viewModel.shareViaEmail(context),
              ),
              ListTile(
                leading: const Icon(Icons.sms, color: Color(0xFF007AFF)), // Azul SMS
                title: const Text('SMS', style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () => _viewModel.shareViaSMS(context),
              ),
              ListTile(
                // Usamos un ícono de chat verde para simular WhatsApp (Material Icons no tiene el logo oficial)
                leading: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366)),
                title: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () => _viewModel.shareViaWhatsApp(context),
              ),
            ],
          ),
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
              image: PetImageHelper.getProvider(_viewModel.imageUrl),
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
                onTap: () => _viewModel.onBackPressed(context),
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
              color: alertRed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _viewModel.status,
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
                  _viewModel.distance,
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
          // Mini mapa fijo centrado en el reporte. Usa un TileLayer con
          // userAgentPackageName, como el mapa principal: OpenStreetMap bloquea
          // ("Access blocked") las descargas directas de tiles sin identificarse.
          FlutterMap(
            options: MapOptions(
              initialCenter: _viewModel.position,
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
                    point: _viewModel.position,
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
                      _viewModel.lastLocation,
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