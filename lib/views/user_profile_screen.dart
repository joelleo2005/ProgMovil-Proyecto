import 'package:flutter/material.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import 'help_center_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final UserProfileViewModel _viewModel;

  static const Color bgColor = Color(0xFFF4EFEB);
  static const Color primaryDark = Color(0xFF332B25);
  static const Color brandBrown = Color(0xFF906A55);
  static const Color textMuted = Color(0xFF8C827A);

  @override
  void initState() {
    super.initState();
    _viewModel = UserProfileViewModel();
    // Escucha activamente el notifyListeners() del ViewModel
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  // Modal deslizable con el formulario
  void _showEditProfileModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _viewModel.name);
    final phoneController = TextEditingController(text: _viewModel.phone);
    final locationController = TextEditingController(text: _viewModel.location);
    String selectedAvatar = _viewModel.avatarUrl;

    final List<String> presetAvatars = [
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=400&q=80',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Editar Datos Personales',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selector de Foto de Perfil
                      const Text(
                        'Selecciona tu foto de perfil',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryDark),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: presetAvatars.map((url) {
                          final isSelected = selectedAvatar == url;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedAvatar = url;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? brandBrown : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundImage: NetworkImage(url),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Campos de texto
                      _buildInputField(
                        label: 'Nombre completo',
                        controller: nameController,
                        icon: Icons.person_outline,
                        validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                      ),
                      const SizedBox(height: 14),
                      _buildInputField(
                        label: 'Teléfono de contacto',
                        controller: phoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Ingresa tu teléfono' : null,
                      ),
                      const SizedBox(height: 14),
                      _buildInputField(
                        label: 'Zona / Distrito',
                        controller: locationController,
                        icon: Icons.location_on_outlined,
                        validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Ingresa tu zona o distrito' : null,
                      ),
                      const SizedBox(height: 24),

                      // Botones Guardar / Cancelar
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(sheetContext),
                              child: const Text('Cancelar', style: TextStyle(color: textMuted)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandBrown,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (formKey.currentState?.validate() ?? false) {
                                  _viewModel.updateProfile(
                                    name: nameController.text,
                                    phone: phoneController.text,
                                    location: locationController.text,
                                    avatarUrl: selectedAvatar,
                                  );
                                  Navigator.pop(sheetContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('¡Datos y avatar actualizados!'),
                                      backgroundColor: brandBrown,
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Guardar',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: primaryDark),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: brandBrown),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            filled: true,
            fillColor: bgColor.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: brandBrown, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Mi Perfil',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
              const SizedBox(height: 20),

              // Tarjeta principal del usuario
              _buildHeaderCard(),
              const SizedBox(height: 16),

              // Métricas de rescate
              _buildStatsRow(),
              const SizedBox(height: 24),

              // Opciones de cuenta
              const Text(
                'Cuenta y Ajustes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(),
              const SizedBox(height: 20),

              // Botón de Cerrar Sesión
              _buildLogoutButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(_viewModel.avatarUrl),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showEditProfileModal(context),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: brandBrown,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _viewModel.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _viewModel.email,
                  style: const TextStyle(fontSize: 13, color: textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: brandBrown),
                    const SizedBox(width: 4),
                    Text(
                      _viewModel.location,
                      style: const TextStyle(fontSize: 12, color: primaryDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: 'Reportes activos',
            value: '${_viewModel.activeReports}',
            icon: Icons.pets,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            label: 'Reunidas',
            value: '${_viewModel.rescuedPets}',
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: brandBrown.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: brandBrown, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: textMuted),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.person_outline,
            title: 'Datos personales',
            subtitle: _viewModel.phone,
            onTap: () => _showEditProfileModal(context),
          ),
          const Divider(height: 1, indent: 56, endIndent: 16),
          _buildListTile(
            icon: Icons.notifications_none,
            title: 'Notificaciones de alerta',
            trailing: Switch.adaptive(
              value: _viewModel.notificationsEnabled,
              activeColor: brandBrown,
              onChanged: (val) {
                _viewModel.toggleNotifications(val);
              },
            ),
          ),
          const Divider(height: 1, indent: 56, endIndent: 16),
          _buildListTile(
            icon: Icons.security,
            title: 'Seguridad y contraseña',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56, endIndent: 16),
          _buildListTile(
            icon: Icons.help_outline,
            title: 'Centro de ayuda',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: brandBrown, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryDark),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12, color: textMuted))
          : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE57373)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.logout, color: Color(0xFFD32F2F), size: 18),
        label: const Text(
          'Cerrar sesión',
          style: TextStyle(
            color: Color(0xFFD32F2F),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        onPressed: () => _viewModel.onLogout(context),
      ),
    );
  }
}