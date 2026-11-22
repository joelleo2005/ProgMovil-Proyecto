/// Funciones de formato de fechas compartidas por varias pantallas
/// (sin paquetes extra como intl).
class Formatters {
  Formatters._();

  static const _months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  /// Ej. "31 ago 2026"
  static String date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// Ej. "10:30 AM"
  static String time(DateTime d) {
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minutes = d.minute.toString().padLeft(2, '0');
    final period = d.hour < 12 ? 'AM' : 'PM';
    return '$hour12:$minutes $period';
  }

  /// Ej. "hace 5 min", "hace 2 h", "hace 3 días"
  static String timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'hace un momento';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'hace 1 día';
    return 'hace ${diff.inDays} días';
  }

  /// Lo contrario de [date] + [time]: convierte "22 nov 2026" y "10:33 AM"
  /// en un DateTime. Devuelve null si el texto no tiene ese formato
  /// (por ejemplo, reportes antiguos donde la fecha se escribió a mano).
  static DateTime? parseDateTime(String date, String time) {
    final dateParts = date.trim().toLowerCase().split(RegExp(r'\s+'));
    if (dateParts.length != 3) return null;
    final day = int.tryParse(dateParts[0]);
    final month = _months.indexOf(dateParts[1]) + 1;
    final year = int.tryParse(dateParts[2]);
    if (day == null || month == 0 || year == null) return null;

    var hour = 0;
    var minute = 0;
    final timeMatch =
        RegExp(r'^(\d{1,2}):(\d{2})\s*([ap]m)$').firstMatch(time.trim().toLowerCase());
    if (timeMatch != null) {
      hour = int.parse(timeMatch.group(1)!) % 12;
      minute = int.parse(timeMatch.group(2)!);
      if (timeMatch.group(3) == 'pm') hour += 12;
    }
    return DateTime(year, month, day, hour, minute);
  }
}
