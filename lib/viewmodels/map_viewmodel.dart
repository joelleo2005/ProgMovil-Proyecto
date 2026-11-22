import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../data/location_service.dart';
import '../models/pet_report_model.dart';
import '../repositories/pet_report_repository.dart';

// Los marcadores del mapa ahora son reportes de Firestore (ver models/).
typedef PetMarker = PetReportModel;

/// ViewModel del mapa. Se crea UNA sola vez en main.dart y lo comparten
/// el mapa y "Crear reporte" (que lee de aquí la ubicación del usuario).
class MapViewModel extends ChangeNotifier {
  final PetReportRepository _reportRepository;
  final LocationService _locationService;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<PetReportModel>>? _reportsSub;

  MapViewModel({
    PetReportRepository? reportRepository,
    LocationService? locationService,
  })  : _reportRepository = reportRepository ?? PetReportRepository(),
        _locationService = locationService ?? LocationService() {
    _initLocation();
    // Como este ViewModel vive toda la app, la escucha de Firestore se
    // reinicia con cada inicio de sesión (y se corta al cerrarla); si no,
    // tras "cerrar sesión" e ingresar de nuevo el mapa quedaría vacío.
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  LatLng _userLocation = LocationService.defaultLocation;
  LatLng get userLocation => _userLocation;

  bool _isLoadingLocation = true;
  bool get isLoadingLocation => _isLoadingLocation;

  String _selectedFilter = 'Todos';
  String get selectedFilter => _selectedFilter;

  final List<String> filters = const ['Todos', 'Perdidos', 'Encontrados', 'Perros', 'Gatos'];

  // Reportes activos sincronizados en tiempo real desde Firestore
  List<PetMarker> _allPets = [];

  void _onAuthChanged(User? user) {
    _reportsSub?.cancel();
    _reportsSub = null;

    if (user == null) {
      _allPets = [];
      notifyListeners();
      return;
    }

    _reportsSub = _reportRepository.watchActiveReports().listen(
      (reports) {
        _allPets = reports;
        notifyListeners();
      },
      onError: (e) => debugPrint('Error leyendo reportes de Firestore: $e'),
    );
  }

  Future<void> _initLocation() async {
    // GPS -> IP (HTTPS) -> Centro de Lima. Ver data/location_service.dart
    _userLocation = await _locationService.getCurrentLocation();
    _isLoadingLocation = false;
    notifyListeners();
  }

  /// Distancia legible entre la ubicación del usuario y un punto.
  String distanceTo(LatLng point) {
    final meters = _locationService.distanceInMeters(_userLocation, point);
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  List<PetMarker> get filteredPets {
    switch (_selectedFilter) {
      case 'Perdidos':
        return _allPets.where((p) => p.isLost).toList();
      case 'Encontrados':
        return _allPets.where((p) => !p.isLost).toList();
      case 'Perros':
        return _allPets.where((p) => p.petType == PetType.perro).toList();
      case 'Gatos':
        return _allPets.where((p) => p.petType == PetType.gato).toList();
      default:
        return _allPets;
    }
  }

  void setFilter(String filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _reportsSub?.cancel();
    super.dispose();
  }
}
