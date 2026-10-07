import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum ReportType { perdida, encontrada }
enum PetType { perro, gato, otro }

class CreateReportViewModel extends ChangeNotifier {
  // Recibimos la ubicación GPS del dispositivo al abrir la pantalla
  CreateReportViewModel({required LatLng initialLocation}) {
    _selectedLocation = initialLocation;
  }

  ReportType _reportType = ReportType.perdida;
  ReportType get reportType => _reportType;

  PetType _petType = PetType.perro;
  PetType get petType => _petType;

  // Cambiamos a 'late' porque la inicializamos en el constructor
  late LatLng _selectedLocation;
  LatLng get selectedLocation => _selectedLocation;

  void setReportType(ReportType type) {
    if (_reportType != type) {
      _reportType = type;
      notifyListeners();
    }
  }

  void setPetType(PetType type) {
    if (_petType != type) {
      _petType = type;
      notifyListeners();
    }
  }

  void updateLocation(LatLng newLocation) {
    _selectedLocation = newLocation;
    notifyListeners();
  }

  Future<void> publishReport() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}