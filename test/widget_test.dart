import 'package:flutter_test/flutter_test.dart';

import 'package:lost_paws/models/pet_report_model.dart';

PetReportModel _report({
  String name = 'Rocky',
  ReportType reportType = ReportType.perdida,
  PetType petType = PetType.perro,
  ReportStatus status = ReportStatus.activo,
}) {
  return PetReportModel(
    ownerId: 'uid_123',
    ownerName: 'María',
    reportType: reportType,
    petType: petType,
    status: status,
    name: name,
    description: 'Se perdió cerca del parque',
    characteristics: 'Collar rojo',
    imageUrl: PetReportModel.defaultImageFor(petType),
    latitude: -12.05,
    longitude: -77.04,
    date: '22 nov 2026',
    time: '10:30 AM',
  );
}

void main() {
  group('PetReportModel', () {
    test('toMap guarda los enums por nombre (como los lee Firestore)', () {
      final map = _report(petType: PetType.gato).toMap();

      expect(map['reportType'], 'perdida');
      expect(map['petType'], 'gato');
      expect(map['status'], 'activo');
      expect(map['ownerId'], 'uid_123');
      expect(map['latitude'], -12.05);
      // createdAt lo pone el servidor, no el cliente.
      expect(map.containsKey('createdAt'), isFalse);
    });

    test('displayName usa "Sin nombre" si el nombre está vacío', () {
      expect(_report(name: '   ').displayName, 'Sin nombre');
      expect(_report(name: 'Luna').displayName, 'Luna');
    });

    test('statusLabel según tipo y estado', () {
      expect(_report().statusLabel, 'Perdido');
      expect(_report(reportType: ReportType.encontrada).statusLabel, 'Encontrado');
      expect(_report(status: ReportStatus.rescatado).statusLabel, 'Rescatado');
    });

    test('isActive e isLost', () {
      expect(_report().isActive, isTrue);
      expect(_report(status: ReportStatus.rescatado).isActive, isFalse);
      expect(_report(reportType: ReportType.encontrada).isLost, isFalse);
    });
  });
}
