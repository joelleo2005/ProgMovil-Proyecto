import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ViewModels
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/map_viewmodel.dart'; // <-- Nuevo import

// Views
import 'views/auth_screen.dart';
import 'views/home_screen.dart';
import 'views/create_report_screen.dart';
import 'views/map_screen.dart';
import 'views/pet_profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MapViewModel()), // <-- Añadido aquí
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
      initialRoute: '/auth',
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