import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'reports_screen.dart';
import 'user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // El MapViewModel se crea una sola vez en main.dart (no aquí), para que
  // el mapa y "Crear reporte" compartan la misma instancia.
  final List<Widget> _screens = const [
    MapScreen(),
    ReportsScreen(),
    UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color brandBrown = Color(0xFF906A55);

    return Scaffold(
      // Se elimina el AppBar para que el mapa ocupe toda la pantalla superior
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: brandBrown,
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home_filled, size: 28),
              ),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.search, size: 28),
              ),
              label: 'Mis reportes',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.chat_bubble_rounded, size: 28),
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}