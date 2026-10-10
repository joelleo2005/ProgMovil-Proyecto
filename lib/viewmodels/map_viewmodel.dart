import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class PetMarker {
  final String id;
  final String imageUrl;
  final LatLng position;
  final bool isLost;

  PetMarker({required this.id, required this.imageUrl, required this.position, required this.isLost});
}

class MapViewModel extends ChangeNotifier {
  // Ubicación por defecto inicial
  LatLng _userLocation = const LatLng(-12.046374, -77.042793);
  LatLng get userLocation => _userLocation;

  bool _isLoadingLocation = true;
  bool get isLoadingLocation => _isLoadingLocation;

  String _selectedFilter = 'Todos';
  String get selectedFilter => _selectedFilter;

  final List<String> filters = ['Todos', 'Perdidos', 'Encontrados', 'Perros'];
  final List<PetMarker> _allPets = []; // Puedes dejar tus mascotas de prueba aquí

  MapViewModel() {
    _initLocation();
  }

  // Lógica principal de inicialización
  Future<void> _initLocation() async {
    try {
      Position position = await _determineGPSPosition();
      _userLocation = LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Fallo el GPS, intentando por IP: $e");
      await _getLocationByIP();
    } finally {
      _allPets.clear();
      _allPets.add(
          PetMarker(
            id: 'rocky_1',
            position: LatLng(
              _userLocation.latitude + 0.0015,
              _userLocation.longitude + 0.0015,
            ),
            imageUrl:
            'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=800&q=80',
            isLost: true,
          ),
      );

      _isLoadingLocation = false;
      notifyListeners(); // Avisa a la UI que ya terminó de cargar
    }
  }

  // Intenta obtener GPS (o red del dispositivo)
  Future<Position> _determineGPSPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Servicios de ubicación deshabilitados.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permisos de ubicación denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permisos denegados permanentemente.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // Plan B: Ubicación por IP usando una API pública gratuita
  Future<void> _getLocationByIP() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _userLocation = LatLng(data['lat'], data['lon']);
          debugPrint("Ubicación obtenida por IP: $_userLocation");
        }
      }
    } catch (e) {
      debugPrint("También falló la ubicación por IP. Se usará la ubicación por defecto.");
    }
  }

  List<PetMarker> get filteredPets {
    if (_selectedFilter == 'Perdidos') return _allPets.where((p) => p.isLost).toList();
    if (_selectedFilter == 'Encontrados') return _allPets.where((p) => !p.isLost).toList();
    return _allPets;
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
}