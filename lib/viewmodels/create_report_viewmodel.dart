import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/report.dart';
import '../repositories/report_repository.dart';
import '../utils/formatters.dart';

class CreateReportViewModel extends ChangeNotifier {
  final ReportRepository _repository;

  // Recibimos la ubicación GPS del dispositivo al abrir la pantalla
  CreateReportViewModel(this._repository, {required LatLng initialLocation})
      : _selectedLocation = initialLocation;

  ReportType _reportType = ReportType.perdida;
  ReportType get reportType => _reportType;

  PetType _petType = PetType.perro;
  PetType get petType => _petType;

  LatLng _selectedLocation;
  LatLng get selectedLocation => _selectedLocation;

  /// Fecha y hora del suceso. Por defecto, ahora mismo.
  DateTime _dateTime = DateTime.now();
  DateTime get dateTime => _dateTime;
  String get dateLabel => Formatters.date(_dateTime);
  String get timeLabel => Formatters.time(_dateTime);

  bool _isSaving = false;
  bool get isSaving => _isSaving;

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

  /// Valida, crea el reporte y lo guarda en el repositorio.
  /// Devuelve el reporte creado, o null si hubo un error (ver [errorMessage]).
  Future<Report?> publishReport({
    required String name,
    required String description,
    required String characteristics,
  }) async {
    if (_dateTime.isAfter(DateTime.now())) {
      _errorMessage = 'La fecha y hora no pueden estar en el futuro.';
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final report = Report(
        id: _repository.newId(),
        type: _reportType,
        petType: _petType,
        name: name.trim().isEmpty ? null : name.trim(),
        description: description.trim(),
        characteristics: characteristics.trim(),
        // Foto provisional según el tipo de mascota, hasta conectar la cámara.
        imageUrl: _placeholderImages[_petType]!,
        location: _selectedLocation,
        date: _dateTime,
        ownerId: ReportRepository.demoCurrentUserId,
        ownerName: ReportRepository.demoCurrentUserName,
        ownerPhone: ReportRepository.demoCurrentUserPhone,
      );
      await _repository.addReport(report);
      return report;
    } catch (e) {
      _errorMessage = 'No se pudo publicar el reporte. Inténtalo de nuevo.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  static const Map<PetType, String> _placeholderImages = {
    PetType.perro:
        'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
    PetType.gato:
        'https://images.unsplash.com/photo-1574158622682-e40e69881006?auto=format&fit=crop&w=800&q=80',
    PetType.otro:
        'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?auto=format&fit=crop&w=800&q=80',
  };
}
