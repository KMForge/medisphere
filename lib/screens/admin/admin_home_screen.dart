import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/logout_confirmation_dialog.dart';
import 'admin_appointments_screen.dart';
import 'admin_users_screen.dart';
import 'add_staff_screen.dart';
import 'inventory_management_screen.dart';
import '../profile/profile_screen.dart';
import '../education/health_education_screen.dart';
import '../health_tracking/health_tracking_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  static const String routeName = '/admin-home';
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _apptService = AppointmentService();
  int _totalAppointments = 0;
  int _pendingAppointments = 0;
  int _confirmedAppointments = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final all = await _apptService.fetchAllAppointments();
    setState(() {
      _totalAppointments = all.length;
      _pendingAppointments = all
          .where((a) => a.status == AppointmentStatus.scheduled)
          .length;
      _confirmedAppointments = all
          .where((a) => a.status == AppointmentStatus.confirmed)
          .length;
      _loading = false;
    });
  }

  void _navigate(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final themeService = context.watch<ThemeService>();
    final isDark = themeService.mode == ThemeMode.dark;
    final userName = auth.currentUser?.fullName ?? 'Admin';

    return Scaffold(
      drawer: _AdminDrawer(
        userName: userName,
        isDark: isDark,
        onNavigate: _navigate,
        onToggleTheme: themeService.toggle,
        onRefresh: _loadStats,
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Panel',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              userName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadStats,
          ),
          IconButton(
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            onPressed: themeService.toggle,
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : AppColors.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => _navigate(ProfileScreen.routeName),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF1A237E),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AdminBanner(userName: userName),
              const SizedBox(height: 24),
              Text(
                'Overview',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Total',
                            value: _totalAppointments,
                            icon: Icons.calendar_month_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Pending',
                            value: _pendingAppointments,
                            icon: Icons.hourglass_top_rounded,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Confirmed',
                            value: _confirmedAppointments,
                            icon: Icons.check_circle_rounded,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 28),
              Text(
                'Management',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.event_available_rounded,
                title: 'Appointments',
                subtitle: 'View, confirm, and manage all appointments',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(
                  context,
                  AdminAppointmentsScreen.routeName,
                ).then((_) => _loadStats()),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.manage_accounts_rounded,
                title: 'Users & Roles',
                subtitle: 'Manage accounts and assign Staff roles',
                color: const Color(0xFF7C3AED),
                onTap: () =>
                    Navigator.pushNamed(context, AdminUsersScreen.routeName),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.person_add_rounded,
                title: 'Add Staff Account',
                subtitle: 'Create new staff or admin accounts',
                color: const Color(0xFF0288D1),
                onTap: () =>
                    Navigator.pushNamed(context, AddStaffScreen.routeName),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.inventory_2_rounded,
                title: 'Medicine Inventory',
                subtitle:
                    'Monitor stock levels and manage medicine availability',
                color: const Color(0xFF00897B),
                onTap: () => Navigator.pushNamed(
                  context,
                  InventoryManagementScreen.routeName,
                ),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.menu_book_rounded,
                title: 'Health Education',
                subtitle: 'Community health guides and tips',
                color: const Color(0xFF388E3C),
                onTap: () => Navigator.pushNamed(
                  context,
                  HealthEducationScreen.routeName,
                ),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.monitor_heart_rounded,
                title: 'Health Tracking',
                subtitle: 'View and monitor health records',
                color: const Color(0xFFE64A19),
                onTap: () => Navigator.pushNamed(
                  context,
                  HealthTrackingScreen.routeName,
                ),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.person_rounded,
                title: 'My Profile',
                subtitle: 'View and edit your admin profile',
                color: const Color(0xFF5C6BC0),
                onTap: () =>
                    Navigator.pushNamed(context, ProfileScreen.routeName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Admin Drawer ────────────────────────────────────────────────────────────

class _AdminDrawer extends StatelessWidget {
  final String userName;
  final bool isDark;
  final void Function(String) onNavigate;
  final VoidCallback onToggleTheme;
  final VoidCallback onRefresh;

  const _AdminDrawer({
    required this.userName,
    required this.isDark,
    required this.onNavigate,
    required this.onToggleTheme,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _AdminDrawerHeader(userName: userName, isDark: isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _AdminDrawerSection(label: 'DASHBOARD'),
                _AdminDrawerItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  color: const Color(0xFF1A237E),
                  onTap: () {
                    Navigator.pop(context);
                    onRefresh();
                  },
                ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                _AdminDrawerSection(label: 'MANAGEMENT'),
                _AdminDrawerItem(
                  icon: Icons.event_available_rounded,
                  label: 'Appointments',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(AdminAppointmentsScreen.routeName);
                  },
                ),
                _AdminDrawerItem(
                  icon: Icons.manage_accounts_rounded,
                  label: 'Users & Roles',
                  color: const Color(0xFF7C3AED),
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(AdminUsersScreen.routeName);
                  },
                ),
                _AdminDrawerItem(
                  icon: Icons.person_add_rounded,
                  label: 'Add Staff Account',
                  color: const Color(0xFF0288D1),
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(AddStaffScreen.routeName);
                  },
                ),
                _AdminDrawerItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Medicine Inventory',
                  color: const Color(0xFF00897B),
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(InventoryManagementScreen.routeName);
                  },
                ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                _AdminDrawerSection(label: 'HEALTH'),
                _AdminDrawerItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Health Education',
                  color: const Color(0xFF388E3C),
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(HealthEducationScreen.routeName);
                  },
                ),
                _AdminDrawerItem(
                  icon: Icons.monitor_heart_rounded,
                  label: 'Health Tracking',
                  color: const Color(0xFFE64A19),
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(HealthTrackingScreen.routeName);
                  },
                ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                _AdminDrawerSection(label: 'ACCOUNT'),
                _AdminDrawerItem(
                  icon: Icons.person_rounded,
                  label: 'My Profile',
                  color: const Color(0xFF5C6BC0),
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(ProfileScreen.routeName);
                  },
                ),
                _AdminDrawerItem(
                  icon: isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  label: isDark ? 'Light Mode' : 'Dark Mode',
                  color: isDark ? Colors.amber : const Color(0xFF37474F),
                  onTap: () {
                    onToggleTheme();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFD32F2F),
                size: 22,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.w700,
                ),
              ),
              horizontalTitleGap: 6,
              dense: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () => LogoutConfirmationDialog.show(context),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _AdminDrawerHeader extends StatelessWidget {
  final String userName;
  final bool isDark;

  const _AdminDrawerHeader({required this.userName, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.22),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Barangay Health Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminDrawerSection extends StatelessWidget {
  final String label;
  const _AdminDrawerSection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminDrawerItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      horizontalTitleGap: 6,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}

class _AdminBanner extends StatelessWidget {
  final String userName;
  const _AdminBanner({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Barangay Health Admin',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome, $userName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Full system access',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
