import 'package:flutter_test/flutter_test.dart';

import 'package:lost_paws/models/pet_report_model.dart';
import 'package:lost_paws/utils/contact_helper.dart';
import 'package:lost_paws/utils/formatters.dart';

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

  group('Formatters', () {
    test('date + time y parseDateTime son inversos', () {
      final original = DateTime(2026, 11, 22, 15, 7);
      final parsed = Formatters.parseDateTime(
        Formatters.date(original),
        Formatters.time(original),
      );
      expect(parsed, original);
    });

    test('parseDateTime entiende AM/PM y medianoche', () {
      expect(Formatters.parseDateTime('1 ene 2026', '12:05 AM'), DateTime(2026, 1, 1, 0, 5));
      expect(Formatters.parseDateTime('1 ene 2026', '12:30 PM'), DateTime(2026, 1, 1, 12, 30));
    });

    test('parseDateTime devuelve null con texto libre', () {
      expect(Formatters.parseDateTime('el lunes pasado', 'tarde'), isNull);
    });
  });

  group('ContactHelper', () {
    test('formatForDialer conserva dígitos y el prefijo +', () {
      expect(ContactHelper.formatForDialer('+51 987 654 321'), '+51987654321');
      expect(ContactHelper.formatForDialer('  987-654-321  '), '987654321');
      expect(ContactHelper.formatForDialer('(01) 431-3040'), '014313040');
      expect(ContactHelper.formatForDialer(''), '');
    });

    test('formatForWhatsApp formatea a dígitos puros y añade prefijo 51 si es celular peruano de 9 dígitos', () {
      expect(ContactHelper.formatForWhatsApp('+51 987 654 321'), '51987654321');
      expect(ContactHelper.formatForWhatsApp('987654321'), '51987654321');
      expect(ContactHelper.formatForWhatsApp('+1 (555) 123-4567'), '15551234567');
      expect(ContactHelper.formatForWhatsApp('51987654321'), '51987654321');
      expect(ContactHelper.formatForWhatsApp(''), '');
    });
  });
}
