import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';

// Importa ambos ViewModels
import '../viewmodels/create_report_viewmodel.dart';
import '../viewmodels/map_viewmodel.dart';

class CreateReportScreen extends StatelessWidget {
  const CreateReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Leemos la ubicación actual del GPS desde el MapViewModel principal
    final userLocation = context.read<MapViewModel>().userLocation;

    return ChangeNotifierProvider(
      // 2. Le pasamos esa ubicación como punto de partida al reporte
      create: (_) => CreateReportViewModel(initialLocation: userLocation),
      child: const _CreateReportView(),
    );
  }
}

class _CreateReportView extends StatefulWidget {
  const _CreateReportView();

  @override
  State<_CreateReportView> createState() => _CreateReportViewState();
}

class _CreateReportViewState extends State<_CreateReportView> {
  // Añadimos el controlador para el mini-mapa
  final MapController _reportMapController = MapController();
  bool _isMapInitialized = false;

  // Controladores del formulario (se envían a Firestore al publicar)
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _characteristicsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _characteristicsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(CreateReportViewModel viewModel) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.dateTime,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now, // no se puede reportar algo que aún no pasó
    );
    if (picked != null) viewModel.setDate(picked);
  }

  Future<void> _pickTime(CreateReportViewModel viewModel) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(viewModel.dateTime),
    );
    if (picked != null) viewModel.setTime(picked);
  }

  Future<void> _publish(CreateReportViewModel viewModel) async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await viewModel.publishReport(
      name: _nameController.text,
      description: _descriptionController.text,
      characteristics: _characteristicsController.text,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Reporte publicado!')),
      );
      // Volvemos al mapa devolviendo la ubicación para centrar la cámara ahí.
      Navigator.pop(context, viewModel.selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'No se pudo publicar.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateReportViewModel>();
    final mapViewModel = context.watch<MapViewModel>();
    const brandBrown = Color(0xFF906A55);

    // Centramos la cámara forzosamente la primera vez que se abre la pantalla
    if (!_isMapInitialized) {
      _isMapInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _reportMapController.move(viewModel.selectedLocation, 15.0);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con botón de regreso
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Crear reporte',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF332D2A)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ¿Qué reportas?
              _buildSectionTitle('¿Qué reportas?'),
              Row(
                children: [
                  Expanded(
                    child: _buildReportTypeCard(
                      title: 'Mascota perdida',
                      icon: Icons.sentiment_dissatisfied,
                      isSelected: viewModel.reportType == ReportType.perdida,
                      onTap: () => viewModel.setReportType(ReportType.perdida),
                      selectedColor: const Color(0xFFFF5252),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildReportTypeCard(
                      title: 'Mascota encontrada',
                      icon: Icons.sentiment_satisfied,
                      isSelected: viewModel.reportType == ReportType.encontrada,
                      onTap: () => viewModel.setReportType(ReportType.encontrada),
                      selectedColor: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Foto de la mascota
              _buildSectionTitle('Foto de la mascota'),
              Row(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.grey.shade400),
                        const SizedBox(height: 4),
                        Text('Cámara', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Foto seleccionada simulada
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          // Imagen que se guardará con el reporte según el tipo de mascota
                          PetReportModel.defaultImageFor(viewModel.petType),
                          height: 100,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.check, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tipo de mascota
              _buildSectionTitle('Tipo de mascota'),
              Row(
                children: [
                  _buildPetTypeChip('Perro', PetType.perro, viewModel),
                  const SizedBox(width: 12),
                  _buildPetTypeChip('Gato', PetType.gato, viewModel),
                  const SizedBox(width: 12),
                  _buildPetTypeChip('Otro', PetType.otro, viewModel),
                ],
              ),
              const SizedBox(height: 24),

              // Formulario de texto
              _buildSectionTitle('Nombre (Si se sabe)'),
              _buildTextField(controller: _nameController, hint: 'Ej. Rocky, Luna...'),
              const SizedBox(height: 16),

              _buildSectionTitle('Descripción'),
              _buildTextField(
                controller: _descriptionController,
                hint: 'Describe dónde lo viste, comportamiento, collar, etc.',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  if (value.trim().length < 10) {
                    return 'Cuéntanos un poco más (mínimo 10 caracteres)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('Color / Características'),
              _buildTextField(controller: _characteristicsController, hint: 'Ej. pelaje dorado, ojos café, collar rojo'),
              const SizedBox(height: 24),


              // Ubicación (Mapa Interactivo)
              _buildSectionTitle('Ubicación (Toca para cambiar el pin)'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 160, // Ligeramente más alto para interactuar cómodamente
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: FlutterMap(
                          mapController: _reportMapController,
                          options: MapOptions(
                            initialCenter: viewModel.selectedLocation,
                            initialZoom: 15.0,
                            // Al tocar el mapa, actualizamos la ubicación en el ViewModel
                            onTap: (tapPosition, point) {
                              viewModel.updateLocation(point);
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.ulima.lostpaws',
                            ),
                            MarkerLayer(
                              markers: [
                                // 1. Indicador de "Dónde estoy" (Punto azul fijo del GPS del usuario)
                                Marker(
                                  point: mapViewModel.userLocation,
                                  width: 16,
                                  height: 16,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                    ),
                                  ),
                                ),
                                // 2. Indicador del "Reporte" (Pin negro interactivo que puedes mover)
                                Marker(
                                  point: viewModel.selectedLocation,
                                  width: 30,
                                  height: 30,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: brandBrown, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              // Muestra las coordenadas exactas redondeadas de forma visual
                              'Lat: ${viewModel.selectedLocation.latitude.toStringAsFixed(4)}, Lng: ${viewModel.selectedLocation.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Fecha y Hora
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Fecha'),
                        _buildPickerField(
                          icon: Icons.calendar_today,
                          label: viewModel.dateLabel,
                          onTap: () => _pickDate(viewModel),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Hora'),
                        _buildPickerField(
                          icon: Icons.access_time,
                          label: viewModel.timeLabel,
                          onTap: () => _pickTime(viewModel),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botón Publicar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.isPublishing ? null : () => _publish(viewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: viewModel.isPublishing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Publicar reporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    int maxLines = 1,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Campo que parece un input pero abre un selector (fecha u hora).
  Widget _buildPickerField({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF906A55)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color selectedColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? selectedColor : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? selectedColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetTypeChip(String label, PetType type, CreateReportViewModel viewModel) {
    final isSelected = viewModel.petType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.setPetType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF906A55) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}