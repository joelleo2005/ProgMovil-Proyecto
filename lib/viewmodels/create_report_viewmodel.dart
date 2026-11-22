import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/pet_report_model.dart';
import '../repositories/pet_report_repository.dart';
import '../repositories/user_repository.dart';
import '../utils/formatters.dart';

// Los enums ahora viven en el modelo; se re-exportan para las vistas.
export '../models/pet_report_model.dart' show ReportType, PetType, PetReportModel;

class CreateReportViewModel extends ChangeNotifier {
  // Recibimos la ubicación GPS del dispositivo al abrir la pantalla
  CreateReportViewModel({
    required LatLng initialLocation,
    PetReportRepository? reportRepository,
    UserRepository? userRepository,
  })  : _reportRepository = reportRepository ?? PetReportRepository(),
        _userRepository = userRepository ?? UserRepository() {
    _selectedLocation = initialLocation;
  }

  final PetReportRepository _reportRepository;
  final UserRepository _userRepository;

  ReportType _reportType = ReportType.perdida;
  ReportType get reportType => _reportType;

  PetType _petType = PetType.perro;
  PetType get petType => _petType;

  // Cambiamos a 'late' porque la inicializamos en el constructor
  late LatLng _selectedLocation;
  LatLng get selectedLocation => _selectedLocation;

  /// Fecha y hora en que se vio a la mascota. Por defecto, ahora mismo.
  DateTime _dateTime = DateTime.now();
  DateTime get dateTime => _dateTime;
  String get dateLabel => Formatters.date(_dateTime); // ej. "22 nov 2026"
  String get timeLabel => Formatters.time(_dateTime); // ej. "10:30 AM"

  /// Cambia el día manteniendo la hora elegida.
  void setDate(DateTime day) {
    _dateTime = DateTime(day.year, day.month, day.day, _dateTime.hour, _dateTime.minute);
    notifyListeners();
  }

  /// Cambia la hora manteniendo el día elegido.
  void setTime(TimeOfDay time) {
    _dateTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day, time.hour, time.minute);
    notifyListeners();
  }

  bool _isPublishing = false;
  bool get isPublishing => _isPublishing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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

  /// Guarda el reporte en Firestore (`pet_reports`). Retorna true si se publicó.
  Future<bool> publishReport({
    required String name,
    required String description,
    required String characteristics,
  }) async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      _errorMessage = 'Debes iniciar sesión para publicar un reporte.';
      notifyListeners();
      return false;
    }
    if (description.trim().isEmpty) {
      _errorMessage = 'Agrega una descripción de la mascota.';
      notifyListeners();
      return false;
    }
    if (_dateTime.isAfter(DateTime.now())) {
      _errorMessage = 'La fecha y hora no pueden estar en el futuro.';
      notifyListeners();
      return false;
    }

    _isPublishing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final owner = await _userRepository.getUser(authUser.uid);
      final report = PetReportModel(
        ownerId: authUser.uid,
        ownerName: owner?.name ?? authUser.displayName ?? '',
        ownerPhone: owner?.phone ?? '',
        reportType: _reportType,
        petType: _petType,
        name: name.trim(),
        description: description.trim(),
        characteristics: characteristics.trim(),
        imageUrl: PetReportModel.defaultImageFor(_petType),
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        // El modelo guarda fecha y hora como texto legible.
        date: dateLabel,
        time: timeLabel,
      );
      await _reportRepository.createReport(report);
      return true;
    } catch (e) {
      _errorMessage = 'No se pudo publicar el reporte: $e';
      return false;
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }
}
