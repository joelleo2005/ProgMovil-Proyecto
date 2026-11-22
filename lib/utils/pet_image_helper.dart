import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

/// Helper para cargar imágenes de mascotas ya sea desde:
/// - URL web (Unsplash / Firebase)
/// - Datos Base64 (fotos tomadas con la cámara o galería)
/// - Archivo local
class PetImageHelper {
  PetImageHelper._();

  /// Retorna un [ImageProvider] adecuado (MemoryImage o NetworkImage)
  /// para usar en [CircleAvatar.backgroundImage] o [DecorationImage.image].
  static ImageProvider getProvider(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final commaIndex = imageUrl.indexOf(',');
        final base64String = commaIndex != -1 ? imageUrl.substring(commaIndex + 1) : imageUrl;
        return MemoryImage(base64Decode(base64String));
      } catch (_) {}
    } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.isNotEmpty) {
      try {
        final file = File(imageUrl);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } catch (_) {}
    }
    return const NetworkImage(
      'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
    );
  }

  /// Retorna un widget [Image] capaz de renderizar tanto URLs web como Base64.
  static Widget buildImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final commaIndex = imageUrl.indexOf(',');
        final base64String = commaIndex != -1 ? imageUrl.substring(commaIndex + 1) : imageUrl;
        return Image.memory(
          base64Decode(base64String),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _placeholder(width, height),
        );
      } catch (_) {}
    } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(width, height),
      );
    } else if (imageUrl.isNotEmpty) {
      try {
        final file = File(imageUrl);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _placeholder(width, height),
          );
        }
      } catch (_) {}
    }
    return _placeholder(width, height);
  }

  static Widget _placeholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.pets, color: Colors.grey, size: 28),
    );
  }
}
