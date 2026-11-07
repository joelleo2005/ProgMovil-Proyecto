import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const Color bgColor = Color(0xFFF4EFEB);
  static const Color primaryDark = Color(0xFF332B25);
  static const Color brandBrown = Color(0xFF906A55);
  static const Color textMuted = Color(0xFF8C827A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Centro de Ayuda',
          style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección 1: ¿Qué hacer si encuentras una mascota?
            _buildSectionTitle('¿Qué hacer si encuentras una mascota?'),
            const SizedBox(height: 10),
            _buildInstructionCard([
              '1. Verifica si tiene placa o collar con número telefónico.',
              '2. Toma fotos claras del animal (rostro, pelaje y marcas distintivas).',
              '3. Llévalo a la veterinaria más cercana para escaneo de microchip.',
              '4. Publica el reporte en LostPaws marcando la ubicación exacta en el mapa.',
              '5. Resguárdalo temporalmente o coordina con un albergue cercano.',
            ]),
            const SizedBox(height: 24),

            // Sección 2: Contactos de Rescate y Emergencia (Perú)
            _buildSectionTitle('Líneas de Ayuda y Rescate (Perú)'),
            const SizedBox(height: 10),
            _buildContactTile(
              title: 'Policía Nacional del Perú (PNP)',
              subtitle: 'Denuncias de abandono o maltrato grave',
              number: '105 / (01) 431-3040',
              icon: Icons.local_police_outlined,
            ),
            const SizedBox(height: 10),
            _buildContactTile(
              title: 'Alerta Serenazgo (Lima Metropolitana)',
              subtitle: 'Rescate en vías públicas o zonas de riesgo',
              number: '(01) 318-5050',
              icon: Icons.shield_outlined,
            ),
            const SizedBox(height: 10),
            _buildContactTile(
              title: 'Red Nacional de Albergues y Rescate',
              subtitle: 'Coordinación ciudadana y hogares temporales',
              number: '+51 989 234 112',
              icon: Icons.pets,
            ),
            const SizedBox(height: 24),

            // Sección 3: Soporte LostPaws
            _buildSectionTitle('Soporte de la Aplicación'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSupportRow(Icons.email_outlined, 'Correo', 'soporte@lostpaws.pe'),
                  const Divider(height: 20),
                  _buildSupportRow(Icons.chat_outlined, 'WhatsApp Soporte', '+51 912 345 678'),
                  const Divider(height: 20),
                  _buildSupportRow(Icons.info_outline, 'Versión de la app', 'v1.0.2 (Beta)'),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: primaryDark,
      ),
    );
  }

  Widget _buildInstructionCard(List<String> steps) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps
            .map(
              (step) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              step,
              style: const TextStyle(fontSize: 13, color: primaryDark, height: 1.4),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildContactTile({
    required String title,
    required String subtitle,
    required String number,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: brandBrown.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: brandBrown, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryDark),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: brandBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: brandBrown),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: textMuted)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primaryDark),
        ),
      ],
    );
  }
}