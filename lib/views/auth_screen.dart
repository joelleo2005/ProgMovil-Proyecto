import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static const Color brandBrown = Color(0xFF906A55);
  static const Color bgColor = Color(0xFFF4EFEB);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth(AuthViewModel viewModel) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await viewModel.authenticate(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: viewModel.isLogin ? null : _nameController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _handleGoogleAuth(AuthViewModel viewModel) async {
    final success = await viewModel.loginWithGoogle();
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Consumer<AuthViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: bgColor,
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
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, brandBrown.withOpacity(0.85)],
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
                        child: Form(
                          key: _formKey,
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
                                _buildTextFormField(
                                  controller: _nameController,
                                  hintText: 'María García',
                                  validator: (val) =>
                                  (val == null || val.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                                ),
                                const SizedBox(height: 16),
                              ],

                              _buildLabel('Correo electrónico'),
                              _buildTextFormField(
                                controller: _emailController,
                                hintText: 'tu@email.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
                                  if (!val.contains('@') || !val.contains('.')) return 'Correo no válido';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildLabel('Contraseña'),
                              _buildTextFormField(
                                controller: _passwordController,
                                hintText: '••••••••',
                                obscureText: viewModel.obscurePassword,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Ingresa tu contraseña';
                                  if (val.length < 6) return 'Mínimo 6 caracteres';
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    viewModel.obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: viewModel.togglePasswordVisibility,
                                ),
                              ),

                              if (viewModel.isLogin) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Enlace de recuperación enviado al correo.'),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      '¿Olvidaste tu contraseña?',
                                      style: TextStyle(color: brandBrown, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 24),
                              ],

                              // Botón Principal
                              ElevatedButton(
                                onPressed: viewModel.isLoading ? null : () => _handleAuth(viewModel),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: brandBrown,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: viewModel.isLoading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                    : Text(
                                  viewModel.isLogin ? 'Iniciar sesión' : 'Crear cuenta',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Separador
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'o continúa con',
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Botón de Google
                              OutlinedButton.icon(
                                onPressed: viewModel.isLoading ? null : () => _handleGoogleAuth(viewModel),
                                icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
                                label: const Text(
                                  'Continuar con Google',
                                  style: TextStyle(color: Colors.black87, fontSize: 15),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFFBF9F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandBrown, width: 1.5),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}