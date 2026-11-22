import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'help_center_screen.dart';
import 'pet_profile_screen.dart';
import '../viewmodels/map_viewmodel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Acerca (+1) o aleja (-1) el mapa, sin salir del rango 3..18.
  void _zoomBy(double delta) {
    final camera = _mapController.camera;
    final zoom = (camera.zoom + delta).clamp(3.0, 18.0);
    _mapController.move(camera.center, zoom);
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: onPressed,
      ),
    );
  }

  /// Busca la zona escrita y mueve el mapa hacia ella.
  Future<void> _search(String query) async {
    FocusScope.of(context).unfocus();
    final viewModel = context.read<MapViewModel>();
    final result = await viewModel.searchPlace(query);
    if (!mounted) return;
    if (result != null) {
      _mapController.move(result, 15.0);
    } else if (viewModel.searchError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.searchError!)),
      );
    }
  }

  /// Menú del mapa: leyenda de colores y accesos rápidos.
  void _showMapMenu(MapViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cómo leer el mapa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildLegendRow(
                color: const Color(0xFFFF5252),
                label: 'Mascota perdida',
                count: viewModel.lostCount,
              ),
              _buildLegendRow(
                color: const Color(0xFF4CAF50),
                label: 'Mascota encontrada',
                count: viewModel.foundCount,
              ),
              _buildLegendRow(color: const Color(0xFF2C2420), label: 'Tu ubicación'),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.my_location),
                title: const Text('Volver a mi ubicación'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _centerMapOnUser(viewModel.userLocation);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.push_pin_outlined),
                title: const Text('Fijar mi ubicación aquí'),
                subtitle: const Text('Usa el centro del mapa como tu ubicación'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  viewModel.setManualLocation(_mapController.camera.center);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ubicación actualizada al centro del mapa.')),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.help_outline),
                title: const Text('Centro de ayuda'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendRow({required Color color, required String label, int? count}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          if (count != null)
            Text('$count', style: const TextStyle(fontSize: 15, color: Colors.grey)),
        ],
      ),
    );
  }

  // Añadimos esta variable para saber si debemos mover la cámara
  LatLng? _lastCenteredLocation;

  void _centerMapOnUser(LatLng location) {
    _mapController.move(location, 15.0);
  }

  /// Abre "Crear reporte". Si se publicó, la pantalla devuelve la ubicación
  /// del reporte y centramos el mapa ahí para que se vea el marcador nuevo.
  Future<void> _openCreateReport() async {
    final result = await Navigator.pushNamed(context, '/create_report');
    if (!mounted || result is! LatLng) return;

    // Si hay un filtro activo, podría ocultar el reporte recién creado.
    context.read<MapViewModel>().setFilter('Todos');
    _mapController.move(result, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();
    const brandBrown = Color(0xFF906A55);

    if (viewModel.isLoadingLocation) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: brandBrown),
            SizedBox(height: 16),
            Text('Ubicándote en el mapa...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // ¡LA MAGIA ESTÁ AQUÍ!
    // Si la ubicación detectada es diferente a la última que centramos
    // (por ejemplo, pasó del centro de Lima a tu GPS real), movemos la cámara.
    if (_lastCenteredLocation != viewModel.userLocation) {
      _lastCenteredLocation = viewModel.userLocation;

      // Esperamos a que el mapa termine de dibujarse en este frame y luego lo movemos
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(viewModel.userLocation, 15.0);
      });
    }

    return Stack(
      children: [
        // 1. Capa Base: El Mapa de OpenStreetMap
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: viewModel.userLocation,
            initialZoom: 15.0,
            // OpenStreetMap solo tiene imágenes hasta el zoom 19; más allá
            // se ve borroso. 3 = ver todo el continente.
            minZoom: 3,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ulima.lostpaws',
            ),
            // Círculo verde claro de radio de búsqueda
            CircleLayer(
              circles: [
                CircleMarker(
                  point: viewModel.userLocation,
                  color: const Color(0xFF4CAF50).withOpacity(0.12),
                  borderColor: Colors.transparent,
                  useRadiusInMeter: true,
                  radius: 400, // Radio de 400 metros
                ),
              ],
            ),
            // Marcadores de mascotas en el mapa
            MarkerLayer(
              markers: viewModel.filteredPets.map((pet) {
                return Marker(
                  point: pet.position,
                  width: 60,
                  height: 75,
                  child: _buildPetMarker(pet),
                );
              }).toList(),
            ),
            // Marcador central (Ubicación del usuario)
            MarkerLayer(
              markers: [
                Marker(
                  point: viewModel.userLocation,
                  width: 30,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2420), // Marrón oscuro
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),

        // 2. Barra de búsqueda superior
        Positioned(
          top: 50,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _search,
                    decoration: InputDecoration(
                      hintText: 'Buscar distrito, calle, parque...',
                      prefixIcon: viewModel.isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => _searchController.clear(),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black87),
                  onPressed: () => _showMapMenu(viewModel),
                ),
              ),
            ],
          ),
        ),

        // 3. Filtros Horizontales (Chips)
        Positioned(
          top: 115,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.filters.length,
              itemBuilder: (context, index) {
                final filter = viewModel.filters[index];
                final isSelected = viewModel.selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => viewModel.setFilter(filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? brandBrown : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Botones de zoom (+ / −), encima del botón de ubicación
        Positioned(
          right: 22,
          bottom: 100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildZoomButton(Icons.add, () => _zoomBy(1)),
                const SizedBox(width: 28, child: Divider(height: 1)),
                _buildZoomButton(Icons.remove, () => _zoomBy(-1)),
              ],
            ),
          ),
        ),

        // 4. Botones Inferiores (+ Reportar y GPS)
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openCreateReport,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Reportar Mascota', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 56,
                width: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  elevation: 0, // Controlado por el box shadow superior
                  onPressed: () => _centerMapOnUser(viewModel.userLocation),
                  child: const Icon(Icons.my_location, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget gráfico con una preview de la mascota buscada
  Widget _buildPetMarker(PetMarker pet) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (sheetContext) => Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(pet.imageUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${pet.statusLabel} · ${context.read<MapViewModel>().distanceTo(pet.position)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF906A55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // 1. Cerramos el BottomSheet usando su propio contexto
                    Navigator.pop(sheetContext);
                    // 2. Navegamos usando el contexto de MapScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetProfileView(report: pet),
                      ),
                    );
                  },
                  child: const Text(
                    'Ver perfil',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(pet.imageUrl),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: pet.isLost
                  ? const Color(0xFFFF5252)
                  : const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}