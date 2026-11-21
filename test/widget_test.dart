import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:lost_paws/models/report.dart';
import 'package:lost_paws/repositories/report_repository.dart';

Report _report({
  required String id,
  ReportType type = ReportType.perdida,
  String ownerId = 'otro',
}) {
  return Report(
    id: id,
    type: type,
    petType: PetType.perro,
    name: 'Test $id',
    description: 'desc',
    imageUrl: 'https://example.com/foto.jpg',
    location: const LatLng(-12.0, -77.0),
    date: DateTime(2026, 11, 21),
    ownerId: ownerId,
    ownerName: 'Tester',
  );
}

void main() {
  group('ReportRepository', () {
    test('addReport agrega el reporte y avisa a los listeners', () async {
      final repo = ReportRepository();
      var notified = 0;
      repo.addListener(() => notified++);

      await repo.addReport(_report(id: 'a'));

      expect(repo.reports.length, 1);
      expect(repo.getById('a')?.name, 'Test a');
      expect(notified, 1);
    });

    test('markResolved saca el reporte de los activos', () async {
      final repo = ReportRepository();
      await repo.addReport(_report(id: 'a'));
      await repo.addReport(_report(id: 'b'));

      await repo.markResolved('a');

      expect(repo.activeReports.map((r) => r.id), ['b']);
      expect(repo.getById('a')?.status, ReportStatus.resuelto);
    });

    test('reportsByOwner filtra por dueño', () async {
      final repo = ReportRepository();
      await repo.addReport(_report(id: 'mio', ownerId: 'yo'));
      await repo.addReport(_report(id: 'ajeno'));

      expect(repo.reportsByOwner('yo').map((r) => r.id), ['mio']);
    });

    test('seedDemoDataIfEmpty no duplica datos', () {
      final repo = ReportRepository();
      repo.seedDemoDataIfEmpty(const LatLng(-12.0, -77.0));
      final count = repo.reports.length;
      repo.seedDemoDataIfEmpty(const LatLng(-12.0, -77.0));

      expect(count, greaterThan(0));
      expect(repo.reports.length, count);
    });
  });

  test('displayName usa un texto por defecto si no hay nombre', () {
    final encontrado = Report(
      id: 'x',
      type: ReportType.encontrada,
      petType: PetType.gato,
      description: '',
      imageUrl: '',
      location: const LatLng(0, 0),
      date: DateTime(2026),
      ownerId: 'o',
      ownerName: 'O',
    );
    expect(encontrado.displayName, 'Mascota encontrada');
  });
}
