import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Servicio que obtiene la ubicación del usuario.
///
/// Orden de intento: 1) GPS del dispositivo, 2) ubicación aproximada por IP,
/// 3) ubicación por defecto (Centro de Lima).
class LocationService {
  static const LatLng defaultLocation = LatLng(-12.046374, -77.042793);

  final http.Client _client;

  LocationService({http.Client? client}) : _client = client ?? http.Client();

  Future<LatLng> getCurrentLocation() async {
    try {
      final position = await _getGpsPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Falló el GPS, intentando por IP: $e');
    }

    final byIp = await _getLocationByIp();
    if (byIp != null) return byIp;

    debugPrint('También falló la ubicación por IP. Se usa la ubicación por defecto.');
    return defaultLocation;
  }

  /// Busca un lugar por nombre (distrito, calle, parque...) usando Nominatim,
  /// el buscador gratuito de OpenStreetMap. Devuelve null si no lo encuentra.
  ///
  /// Nominatim exige identificar la app con un User-Agent y no hacer más de
  /// una búsqueda por segundo (por eso solo buscamos al presionar "Buscar").
  Future<LatLng?> searchPlace(String query) async {
    final text = query.trim();
    if (text.isEmpty) return null;

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': text,
      'format': 'json',
      'limit': '1',
      'accept-language': 'es',
    });
    final response = await _client.get(uri, headers: {
      'User-Agent': 'LostPaws/1.0 (proyecto universitario Universidad de Lima)',
    }).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;

    final results = json.decode(response.body) as List<dynamic>;
    if (results.isEmpty) return null;
    final first = results.first as Map<String, dynamic>;
    final lat = double.tryParse('${first['lat']}');
    final lon = double.tryParse('${first['lon']}');
    if (lat == null || lon == null) return null;
    return LatLng(lat, lon);
  }

  /// Distancia en metros entre dos puntos.
  double distanceInMeters(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(a.latitude, a.longitude, b.latitude, b.longitude);
  }

  Future<Position> _getGpsPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Servicios de ubicación deshabilitados.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permisos de ubicación denegados.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permisos denegados permanentemente.');
    }

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /// Plan B: ubicación aproximada por IP.
  /// Usa HTTPS porque Android bloquea las conexiones HTTP sin cifrar.
  Future<LatLng?> _getLocationByIp() async {
    try {
      final response = await _client
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final lat = data['latitude'];
      final lon = data['longitude'];
      if (lat is num && lon is num) {
        return LatLng(lat.toDouble(), lon.toDouble());
      }
    } catch (e) {
      debugPrint('Error obteniendo ubicación por IP: $e');
    }
    return null;
  }
}
