import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/logout_confirmation_dialog.dart';
import '../admin/admin_appointments_screen.dart';
import '../admin/inventory_management_screen.dart';
import '../education/health_education_screen.dart';
import '../health_tracking/health_tracking_screen.dart';
import '../profile/profile_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  static const String routeName = '/staff-home';
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  final _service = AppointmentService();
  List<AppointmentModel> _pending = [];
  List<AppointmentModel> _confirmed = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final all = await _service.fetchAllAppointments();
    setState(() {
      _pending = all
          .where((a) => a.status == AppointmentStatus.scheduled)
          .toList();
      _confirmed = all
          .where((a) => a.status == AppointmentStatus.confirmed)
          .toList();
      _loading = false;
    });
  }

  Future<void> _confirm(AppointmentModel appt) async {
    await _service.updateAppointmentStatus(
      appt.id,
      AppointmentStatus.confirmed,
    );
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment confirmed!'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Future<void> _cancel(AppointmentModel appt) async {
    await _service.updateAppointmentStatus(
      appt.id,
      AppointmentStatus.cancelled,
    );
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment cancelled.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _complete(AppointmentModel appt) async {
    await _service.updateAppointmentStatus(
      appt.id,
      AppointmentStatus.completed,
    );
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment marked complete.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigate(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final themeService = context.watch<ThemeService>();
    final isDark = themeService.mode == ThemeMode.dark;
    final userName = auth.currentUser?.fullName ?? 'Staff';

    return Scaffold(
      drawer: _StaffDrawer(
        userName: userName,
        isDark: isDark,
        onNavigate: _navigate,
        onToggleTheme: themeService.toggle,
        onRefresh: _load,
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
              'Staff Portal',
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
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
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
                backgroundColor: Color(0xFF00695C),
                child: Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StaffBanner(
                      pending: _pending.length,
                      confirmed: _confirmed.length,
                    ),
                    const SizedBox(height: 24),
                    if (_pending.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Pending Requests',
                        count: _pending.length,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 10),
                      ..._pending.map(
                        (a) => _StaffAppointmentCard(
                          appointment: a,
                          onConfirm: () => _confirm(a),
                          onCancel: () => _cancel(a),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (_confirmed.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Confirmed Today',
                        count: _confirmed.length,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 10),
                      ..._confirmed.map(
                        (a) => _StaffAppointmentCard(
                          appointment: a,
                          onComplete: () => _complete(a),
                          onCancel: () => _cancel(a),
                        ),
                      ),
                    ],
                    if (_pending.isEmpty && _confirmed.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 64,
                                color: Colors.green.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'All caught up!',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'No pending or confirmed appointments.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StaffBanner extends StatelessWidget {
  final int pending;
  final int confirmed;
  const _StaffBanner({required this.pending, required this.confirmed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF00897B), Color(0xFF26A69A)],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Barangay Staff',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Appointment Queue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _BannerStat(
                label: 'Pending',
                value: pending,
                color: Colors.orange,
              ),
              const SizedBox(width: 16),
              _BannerStat(
                label: 'Confirmed',
                value: confirmed,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _BannerStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _StaffAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const _StaffAppointmentCard({
    required this.appointment,
    this.onConfirm,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dt = appointment.dateTime;
    final dateStr =
        '${dt.month}/${dt.day}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final isPending = appointment.status == AppointmentStatus.scheduled;
    final borderColor = isPending ? Colors.orange : Colors.teal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withOpacity(0.35), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: borderColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.service,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPending ? 'Pending' : 'Confirmed',
                  style: TextStyle(
                    color: borderColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (appointment.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: ${appointment.notes}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              if (onConfirm != null)
                Expanded(
                  child: _Btn(
                    label: 'Confirm',
                    icon: Icons.check_circle_outline_rounded,
                    color: Colors.teal,
                    onTap: onConfirm!,
                  ),
                ),
              if (onConfirm != null) const SizedBox(width: 8),
              if (onComplete != null)
                Expanded(
                  child: _Btn(
                    label: 'Complete',
                    icon: Icons.task_alt_rounded,
                    color: Colors.green,
                    onTap: onComplete!,
                  ),
                ),
              if (onComplete != null) const SizedBox(width: 8),
              if (onCancel != null)
                Expanded(
                  child: _Btn(
                    label: 'Cancel',
                    icon: Icons.cancel_outlined,
                    color: Colors.redAccent,
                    onTap: onCancel!,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _Btn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Staff Drawer ─────────────────────────────────────────────────────────────

class _StaffDrawer extends StatelessWidget {
  final String userName;
  final bool isDark;
  final void Function(String) onNavigate;
  final VoidCallback onToggleTheme;
  final VoidCallback onRefresh;

  const _StaffDrawer({
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
          _StaffDrawerHeader(userName: userName, isDark: isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _StaffDrawerSection(label: 'DASHBOARD'),
                _StaffDrawerItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  color: const Color(0xFF00695C),
                  onTap: () {
                    Navigator.pop(context);
                    onRefresh();
                  },
                ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                _StaffDrawerSection(label: 'MANAGEMENT'),
                _StaffDrawerItem(
                  icon: Icons.event_available_rounded,
                  label: 'All Appointments',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(AdminAppointmentsScreen.routeName);
                  },
                ),
                _StaffDrawerItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Medicine Inventory',
                  color: const Color(0xFF00897B),
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(InventoryManagementScreen.routeName);
                  },
                ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                _StaffDrawerSection(label: 'HEALTH'),
                _StaffDrawerItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Health Education',
                  color: const Color(0xFF388E3C),
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(HealthEducationScreen.routeName);
                  },
                ),
                _StaffDrawerItem(
                  icon: Icons.monitor_heart_rounded,
                  label: 'Health Tracking',
                  color: const Color(0xFFE64A19),
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(HealthTrackingScreen.routeName);
                  },
                ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                _StaffDrawerSection(label: 'ACCOUNT'),
                _StaffDrawerItem(
                  icon: Icons.person_rounded,
                  label: 'My Profile',
                  color: const Color(0xFF5C6BC0),
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(ProfileScreen.routeName);
                  },
                ),
                _StaffDrawerItem(
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

class _StaffDrawerHeader extends StatelessWidget {
  final String userName;
  final bool isDark;

  const _StaffDrawerHeader({required this.userName, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF00897B), Color(0xFF26A69A)],
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
              Icons.medical_services_rounded,
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
              'Barangay Staff',
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

class _StaffDrawerSection extends StatelessWidget {
  final String label;
  const _StaffDrawerSection({required this.label});

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

class _StaffDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StaffDrawerItem({
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
