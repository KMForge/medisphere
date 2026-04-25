import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  final bool embedded;

  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _roleController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _nameController = TextEditingController(
      text: user?.fullName ?? 'Barangay Admin',
    );
    _usernameController = TextEditingController(
      text: user?.username ?? 'admin',
    );
    _emailController = TextEditingController(
      text: user?.email ?? 'admin@barangay.ph',
    );
    _roleController = TextEditingController(
      text: user?.role ?? 'Barangay Health Admin',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    final user = AuthService.instance.currentUser;
    if (!_isEditing && user != null) {
      _nameController.text = user.fullName;
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _roleController.text = user.role;
    }
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _saveProfile() async {
    await AuthService.instance.updateProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      role: _roleController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    setState(() => _isEditing = false);
  }

  Widget _buildBody(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accentBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: AppColors.primary, size: 52),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Change photo (UI only).')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _nameController.text,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            _usernameController.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileField(
                  label: 'Full Name',
                  controller: _nameController,
                  enabled: _isEditing,
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 12),
                _ProfileField(
                  label: 'Username',
                  controller: _usernameController,
                  enabled: false,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _ProfileField(
                  label: 'Email',
                  controller: _emailController,
                  enabled: _isEditing,
                  icon: Icons.mail_outline,
                ),
                const SizedBox(height: 12),
                _ProfileField(
                  label: 'Role',
                  controller: _roleController,
                  enabled: _isEditing,
                  icon: Icons.workspace_premium_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isEditing ? _saveProfile : null,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Save changes'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: 'Logout',
                  onPressed: () async {
                    await AuthService.instance.logout();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      LoginScreen.routeName,
                      (_) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _toggleEdit,
                  icon: Icon(_isEditing ? Icons.close : Icons.edit),
                  tooltip: _isEditing ? 'Cancel' : 'Edit profile',
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(context)),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _toggleEdit,
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final IconData icon;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
