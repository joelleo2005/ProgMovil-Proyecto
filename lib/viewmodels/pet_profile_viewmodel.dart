import 'package:flutter/material.dart';

class PetProfileViewModel extends ChangeNotifier {
  // Datos de la mascota
  final String name = 'Rocky';
  final String category = 'Perro · Golden Retriever · Macho';
  final String status = 'Perdido';
  final String distance = '0.3 km';

  final List<String> tags = const [
    '31 ago 2026',
    '10:30 AM',
    'Collar rojo',
  ];

  final String description =
      'Rocky se perdió cerca del parque Lincoln el lunes en la tarde. '
      'Tiene 3 años, es muy cariñoso y responde a su nombre. Lleva '
      'collar rojo con placa. Fue visto por última vez corriendo hacia la '
      'Av. Insurgentes.';

  final Map<String, String> features = const {
    'Color': 'Dorado / Arena',
    'Tamaño': 'Grande (~30 kg)',
    'Edad': '3 años',
    'Señas': 'Cicatriz oreja der.',
  };

  final String lastLocation = 'Av. Insurgentes, Lima · Hace 5 min';
  final String imageUrl =
      'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=800&q=80';
  final String mapUrl =
      'https://tile.openstreetmap.org/15/9480/16280.png';

  // Datos del contacto
  final String ownerInitials = 'MG';
  final String ownerName = 'María Gonzalez';
  final String publishInfo = 'Publicado hace 2 horas · 4 reportes';

  void shareViaGmail(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abriendo Gmail...')),
    );
  }

  void shareViaEmail(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abriendo aplicación de correo...')),
    );
  }

  void shareViaSMS(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abriendo mensajes SMS...')),
    );
  }

  void shareViaWhatsApp(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abriendo WhatsApp...')),
    );
  }

  void onBackPressed(BuildContext context) {
    Navigator.maybePop(context);
  }

  void onContactOwner(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Iniciando llamada con $ownerName...')),
    );
  }

  void onEditReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abriendo edición de reporte...')),
    );
  }

  void onMarkRescued(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Mascota marcada como rescatada!')),
    );
  }
}