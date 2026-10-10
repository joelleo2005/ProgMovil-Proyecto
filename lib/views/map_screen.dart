import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'pet_profile_screen.dart';
import '../viewmodels/map_viewmodel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Añadimos esta variable para saber si debemos mover la cámara
  LatLng? _lastCenteredLocation;

  void _centerMapOnUser(LatLng location) {
    _mapController.move(location, 15.0);
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
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar zona, colonia...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
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
                  onPressed: () {},
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

        // 4. Botones Inferiores (+ Reportar y GPS)
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create_report');
                  },
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PetProfileView(), // o PetProfileScreen() según el nombre de tu clase
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