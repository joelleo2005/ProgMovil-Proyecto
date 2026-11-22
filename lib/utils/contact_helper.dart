import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Funciones auxiliares para abrir la app de llamadas y WhatsApp.
class ContactHelper {
  ContactHelper._();

  /// Limpia el número para el teclado de llamadas (tel:).
  /// Conserva únicamente dígitos y el signo '+' si lo tiene al inicio.
  static String formatForDialer(String rawPhone) {
    final trimmed = rawPhone.trim();
    if (trimmed.isEmpty) return '';
    final hasPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    return hasPlus ? '+$digits' : digits;
  }

  /// Limpia y formatea el número para WhatsApp.
  /// WhatsApp requiere solo dígitos en formato internacional (sin '+', guiones ni espacios).
  /// Si tiene 9 dígitos empezando en 9 (formato celular peruano), se le agrega el código 51.
  static String formatForWhatsApp(String rawPhone) {
    String digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.length == 9 && digits.startsWith('9')) {
      digits = '51$digits';
    }
    return digits;
  }

  /// Verifica si WhatsApp está instalado en el dispositivo.
  static Future<bool> isWhatsAppInstalled() async {
    try {
      final uri = Uri.parse('whatsapp://send');
      return await canLaunchUrl(uri);
    } catch (e) {
      debugPrint('Error comprobando instalación de WhatsApp: $e');
      return false;
    }
  }

  /// Abre la aplicación del teléfono en el apartado de teclado (keypad)
  /// con el número ya llenado, SIN iniciar la llamada automáticamente.
  static Future<bool> openPhoneDialer(String phone) async {
    final formattedPhone = formatForDialer(phone);
    if (formattedPhone.isEmpty) return false;

    final uri = Uri(scheme: 'tel', path: formattedPhone);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (e) {
      debugPrint('Error abriendo teclado de llamadas: $e');
      return false;
    }
  }

  /// Abre WhatsApp en un nuevo chat con el número registrado.
  static Future<bool> openWhatsAppChat(String phone) async {
    final formattedPhone = formatForWhatsApp(phone);
    if (formattedPhone.isEmpty) return false;

    // 1. Intentar abrir directamente la app nativa de WhatsApp
    final nativeUri = Uri.parse('whatsapp://send?phone=$formattedPhone');
    try {
      if (await canLaunchUrl(nativeUri)) {
        return await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error abriendo intent nativo de WhatsApp: $e');
    }

    // 2. Fallback a URL web wa.me
    try {
      final webUri = Uri.parse('https://wa.me/$formattedPhone');
      if (await canLaunchUrl(webUri)) {
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error abriendo fallback wa.me: $e');
    }

    return false;
  }
}
