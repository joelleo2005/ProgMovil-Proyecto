import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Repositories
import 'repositories/report_repository.dart';

// ViewModels
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/map_viewmodel.dart';

// Views
import 'views/auth_screen.dart';
import 'views/home_screen.dart';
import 'views/create_report_screen.dart';
import 'views/map_screen.dart';
import 'views/pet_profile_screen.dart';

void main() {
  runApp(const LostPawsApp());
}

class LostPawsApp extends StatelessWidget {
  const LostPawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Fuente única de reportes: se crea una sola vez para toda la app.
        ChangeNotifierProvider(create: (_) => ReportRepository()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        // Un solo MapViewModel compartido por el mapa y "Crear reporte".
        ChangeNotifierProvider(
          create: (context) => MapViewModel(context.read<ReportRepository>()),
        ),
      ],
      child: MaterialApp(
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
          // Uso: Navigator.pushNamed(context, '/pet_profile', arguments: report.id)
          '/pet_profile': (context) => PetProfileView(
                reportId: ModalRoute.of(context)!.settings.arguments as String,
              ),
        },
      ),
    );
  }
}
