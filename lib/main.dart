import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Firebase
import 'data/firebase_options.dart';

// ViewModels
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/map_viewmodel.dart'; // <-- Nuevo import

// Views
import 'views/auth_screen.dart';
import 'views/home_screen.dart';
import 'views/create_report_screen.dart';
import 'views/map_screen.dart';
import 'views/pet_profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        // Un solo MapViewModel para toda la app (mapa + "Crear reporte").
        ChangeNotifierProvider(create: (_) => MapViewModel()),
      ],
      child: const LostPawsApp(),
    ),
  );
}

class LostPawsApp extends StatelessWidget {
  const LostPawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LostPaws',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        primaryColor: const Color(0xFF906A55),
        fontFamily: 'Roboto',
      ),
      // Si ya hay una sesión de Firebase activa, entramos directo al inicio.
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/auth' : '/home',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/map': (context) => const MapScreen(),
        '/create_report': (context) => const CreateReportScreen(),
        '/pet_profile': (context) => const PetProfileView(),
      },
    );
  }
}