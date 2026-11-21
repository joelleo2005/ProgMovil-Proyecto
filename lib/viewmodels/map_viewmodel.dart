import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../data/location_service.dart';
import '../models/report.dart';
import '../repositories/report_repository.dart';

class MapViewModel extends ChangeNotifier {
  final ReportRepository _repository;
  final LocationService _locationService;

  MapViewModel(this._repository, {LocationService? locationService})
      : _locationService = locationService ?? LocationService() {
    // Cuando el repositorio cambia (p. ej. se crea un reporte), el mapa se redibuja.
    _repository.addListener(_onReportsChanged);
    _initLocation();
  }

  LatLng _userLocation = LocationService.defaultLocation;
  LatLng get userLocation => _userLocation;

  bool _isLoadingLocation = true;
  bool get isLoadingLocation => _isLoadingLocation;

  String _selectedFilter = 'Todos';
  String get selectedFilter => _selectedFilter;

  final List<String> filters = const ['Todos', 'Perdidos', 'Encontrados', 'Perros', 'Gatos'];

  Future<void> _initLocation() async {
    _userLocation = await _locationService.getCurrentLocation();

    // Datos de prueba mientras no hay backend (se quita al conectar Firebase).
    _repository.seedDemoDataIfEmpty(_userLocation);

    _isLoadingLocation = false;
    notifyListeners();
  }

  /// Reportes activos que pasan el filtro seleccionado.
  List<Report> get filteredReports {
    final reports = _repository.activeReports;
    switch (_selectedFilter) {
      case 'Perdidos':
        return reports.where((r) => r.isLost).toList();
      case 'Encontrados':
        return reports.where((r) => !r.isLost).toList();
      case 'Perros':
        return reports.where((r) => r.petType == PetType.perro).toList();
      case 'Gatos':
        return reports.where((r) => r.petType == PetType.gato).toList();
      default:
        return reports;
    }
  }

  void setFilter(String filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
  }

  /// Distancia legible desde el usuario hasta el reporte (ej. "350 m", "1.2 km").
  String distanceLabel(Report report) {
    final meters = _locationService.distanceInMeters(_userLocation, report.location);
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  void _onReportsChanged() => notifyListeners();

  @override
  void dispose() {
    _repository.removeListener(_onReportsChanged);
    super.dispose();
  }
}
