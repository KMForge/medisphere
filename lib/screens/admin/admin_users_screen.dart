import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import 'add_staff_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  static const String routeName = '/admin-users';
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  static const _roles = ['User', 'Barangay Staff', 'Barangay Health Admin'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await AuthService.instance.getAllUsers();
    setState(() {
      _users = data;
      _loading = false;
    });
  }

  Future<void> _changeRole(String userId, String newRole) async {
    await AuthService.instance.updateUserRole(userId, newRole);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Role updated to "$newRole".')));
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Barangay Health Admin':
        return const Color(0xFF1A237E);
      case 'Barangay Staff':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'Barangay Health Admin':
        return Icons.admin_panel_settings_rounded;
      case 'Barangay Staff':
        return Icons.medical_services_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService.instance.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users & Roles'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          AddStaffScreen.routeName,
        ).then((_) => _load()),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Staff'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? const Center(child: Text('No users found.'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                itemBuilder: (context, i) {
                  final u = _users[i];
                  final uid = u['id'] as String? ?? '';
                  final role = u['role'] as String? ?? 'User';
                  final name = u['full_name'] as String? ?? 'Unknown';
                  final email = u['email'] as String? ?? '';
                  final isSelf = uid == currentUserId;
                  final roleColor = _roleColor(role);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: roleColor.withOpacity(0.25),
                        width: 1.2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: roleColor.withOpacity(0.12),
                          ),
                          child: Icon(
                            _roleIcon(role),
                            color: roleColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isSelf) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'You',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                email,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: roleColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  role,
                                  style: TextStyle(
                                    color: roleColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isSelf)
                          PopupMenuButton<String>(
                            tooltip: 'Change role',
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: AppColors.textSecondary,
                            ),
                            onSelected: (newRole) => _changeRole(uid, newRole),
                            itemBuilder: (_) => _roles
                                .where((r) => r != role)
                                .map(
                                  (r) => PopupMenuItem(
                                    value: r,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _roleIcon(r),
                                          color: _roleColor(r),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(r),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
