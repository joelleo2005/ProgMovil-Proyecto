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
}
