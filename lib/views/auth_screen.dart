import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    const Color brandBrown = Color(0xFF906A55);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo y Título
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: brandBrown,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.pets, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'LostPaws',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Hero Image con gradiente y texto
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1543466835-00a7907e9de1'), // Reemplazar con asset local
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, brandBrown.withOpacity(0.8)],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.bottomLeft,
                    child: const Text(
                      'Ayudemos a que\nvuelvan a casa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Formulario (Tarjeta Blanca)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Toggle Switch
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F1EE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => viewModel.toggleAuthMode(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: viewModel.isLogin ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: viewModel.isLogin
                                        ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Iniciar sesión',
                                    style: TextStyle(
                                      color: viewModel.isLogin ? Colors.black87 : Colors.black54,
                                      fontWeight: viewModel.isLogin ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => viewModel.toggleAuthMode(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !viewModel.isLogin ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: !viewModel.isLogin
                                        ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Registrarme',
                                    style: TextStyle(
                                      color: !viewModel.isLogin ? Colors.black87 : Colors.black54,
                                      fontWeight: !viewModel.isLogin ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Campos dinámicos
                      if (!viewModel.isLogin) ...[
                        _buildLabel('Nombre Completo'),
                        _buildTextField(hintText: 'María García'),
                        const SizedBox(height: 16),
                      ],

                      _buildLabel('Correo electrónico'),
                      _buildTextField(hintText: 'tu@email.com', keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),

                      _buildLabel('Contraseña'),
                      _buildTextField(
                        hintText: '***********',
                        obscureText: viewModel.obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            viewModel.obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: viewModel.togglePasswordVisibility,
                        ),
                      ),

                      if (viewModel.isLogin) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 24),
                      ],

                      // Botón Principal
                      ElevatedButton(
                        onPressed: () => viewModel.authenticate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandBrown,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          viewModel.isLogin ? 'Iniciar sesión' : 'Crear cuenta',
                          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Separador
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('o continúa con', style: TextStyle(color: Colors.grey.shade500)),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Botón de Google
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: Image.network(
                          'https://static.vecteezy.com/system/resources/thumbnails/028/667/072/small_2x/google-logo-icon-symbol-free-png.png',
                          height: 24,
                        ), // Reemplazar con asset local SVG/PNG
                        label: const Text(
                          'Continuar con Google',
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFFBF9F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}