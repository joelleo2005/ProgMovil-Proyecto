// lib/data/firebase_options.dart
//
// Configuración manual de Firebase (ver teoría Semana 10, diapositiva 13).
// Completa los valores con los datos del archivo
// android/app/google-services.json descargado desde la consola de Firebase:
//
//   apiKey            -> client[0].api_key[0].current_key
//   appId             -> client[0].client_info.mobilesdk_app_id
//   messagingSenderId -> project_info.project_number
//   projectId         -> project_info.project_id
//   storageBucket     -> project_info.storage_bucket
//
// Alternativa automática: `flutterfire configure` genera este archivo
// (en lib/firebase_options.dart); si lo usas, actualiza el import en main.dart.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions no está configurado para Web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // --- Android Configuration ---
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_PQYk08L8pikcm4JRwK3FINU9Eu7inIo',
    appId: '1:1045318540713:android:05355f7f2a1e4da4e8b8b8',
    messagingSenderId: '1045318540713',
    projectId: 'lostpaws-b832a',
    storageBucket: 'lostpaws-b832a.firebasestorage.app',
  );

  // --- iOS Configuration ---
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
    iosBundleId: 'com.example.lostPaws',
  );
}
