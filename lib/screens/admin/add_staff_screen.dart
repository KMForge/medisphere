import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AddStaffScreen extends StatefulWidget {
  static const String routeName = '/admin-add-staff';
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'Barangay Staff';
  bool _isLoading = false;

  static const _roles = ['Barangay Staff', 'Barangay Health Admin'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final error = await AuthService.instance.adminCreateUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      role: _selectedRole,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staff account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Staff Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Details',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Full Name',
                hint: 'e.g., Juan Dela Cruz',
                controller: _nameController,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Username',
                hint: 'e.g., juandelacruz',
                controller: _usernameController,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Email',
                hint: 'staff@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Password',
                hint: 'Min 6 characters',
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Phone (optional)',
                hint: '+639123456789',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              Text(
                'Assign Role',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ..._roles.map((role) {
                return RadioListTile<String>(
                  value: role,
                  groupValue: _selectedRole,
                  onChanged: (v) => setState(() => _selectedRole = v!),
                  title: Text(role),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const SizedBox(height: 32),
              CustomButton(
                label: _isLoading ? 'Creating...' : 'Create Account',
                onPressed: _isLoading ? () {} : _create,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
