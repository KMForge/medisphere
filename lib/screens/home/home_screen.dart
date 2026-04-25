import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/family_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/logout_confirmation_dialog.dart';
import '../../widgets/chat_floating_button.dart';
import '../emergency/emergency_confirmation_dialog.dart';
import '../emergency/emergency_type_screen.dart';
import '../family/family_management_screen.dart';
import '../family/profile_switcher_screen.dart';
import '../../services/theme_service.dart';
import '../appointment/appointment_history_screen.dart';
import '../appointment/book_appointment_screen.dart';
import '../education/health_education_screen.dart';
import '../health_tracking/health_tracking_screen.dart';
import '../profile/profile_screen.dart';
import '../reminders/reminders_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final AnimationController _fabController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  static const _tabTitles = [
    'Home',
    'Book Appointment',
    'Health Tracking',
    'Reminders',
    'Profile',
  ];

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _navigate(String route) {
    Navigator.pushNamed(context, route);
  }

  void _switchTab(int index) => setState(() => _currentIndex = index);

  Future<void> _showEmergencyDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => EmergencyConfirmationDialog(
        onConfirm: () =>
            Navigator.pushNamed(context, EmergencyTypeScreen.routeName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final themeService = context.watch<ThemeService>();
    final isDark = themeService.mode == ThemeMode.dark;
    final user = authService.currentUser;
    final userName = user?.fullName ?? 'Barangay Admin';
    final userRole = user?.role ?? 'Barangay Health Admin';

    return Scaffold(
      drawer: _AppDrawer(
        userName: userName,
        userRole: userRole,
        isDark: isDark,
        onNavigate: _navigate,
        onToggleTheme: themeService.toggle,
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: _currentIndex == 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good day,',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )
            : Text(
                _tabTitles[_currentIndex],
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
        actions: [
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
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _DashboardView(onNavigate: _navigate, userName: userName),
              const BookAppointmentScreen(embedded: true),
              const HealthTrackingScreen(embedded: true),
              const RemindersScreen(embedded: true),
              const ProfileScreen(embedded: true),
            ],
          ),
          // Chat floating button
          if (_currentIndex != 3) // Hide on Reminders tab
            const ChatFloatingButton(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _currentIndex == 3
          ? null
          : ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.06).animate(
                CurvedAnimation(
                  parent: _fabController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: SizedBox(
                width: 66,
                height: 66,
                child: FloatingActionButton(
                  heroTag: 'emergency_fab',
                  backgroundColor: const Color(0xFFD32F2F),
                  tooltip: 'Emergency Help',
                  onPressed: _showEmergencyDialog,
                  child: const Icon(
                    Icons.emergency_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onNavigate: _navigate,
        onSwitchTab: _switchTab,
      ),
    );
  }
}

// ─── Sidebar Drawer ──────────────────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  final String userName;
  final String userRole;
  final bool isDark;
  final void Function(String) onNavigate;
  final VoidCallback onToggleTheme;

  const _AppDrawer({
    required this.userName,
    required this.userRole,
    required this.isDark,
    required this.onNavigate,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _DrawerHeader(userName: userName, userRole: userRole, isDark: isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerSection(label: 'MAIN'),
                _DrawerItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.event_available_rounded,
                  label: 'Book Appointment',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(BookAppointmentScreen.routeName);
                  },
                ),
                _DrawerItem(
                  icon: Icons.history_rounded,
                  label: 'Appointment History',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(AppointmentHistoryScreen.routeName);
                  },
                ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                _DrawerSection(label: 'HEALTH'),
                _DrawerItem(
                  icon: Icons.monitor_heart_rounded,
                  label: 'Health Tracking',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(HealthTrackingScreen.routeName);
                  },
                ),
                _DrawerItem(
                  icon: Icons.alarm_rounded,
                  label: 'Health Reminders',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(RemindersScreen.routeName);
                  },
                ),
                _DrawerItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Health Education',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(HealthEducationScreen.routeName);
                  },
                ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                _DrawerSection(label: 'FAMILY & ACCOUNT'),
                _DrawerItem(
                  icon: Icons.group_rounded,
                  label: 'Family Monitoring',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(FamilyManagementScreen.routeName);
                  },
                ),
                _DrawerItem(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Switch Profile',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(ProfileSwitcherScreen.routeName);
                  },
                ),
                _DrawerItem(
                  icon: Icons.person_rounded,
                  label: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(ProfileScreen.routeName);
                  },
                ),
                const Divider(indent: 16, endIndent: 16, height: 24),
                _DrawerItem(
                  icon: isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  label: isDark ? 'Light Mode' : 'Dark Mode',
                  onTap: () {
                    onToggleTheme();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          _DrawerLogoutTile(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final bool isDark;

  const _DrawerHeader({
    required this.userName,
    required this.userRole,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Icon(Icons.person, size: 32, color: Colors.white),
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
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              userRole,
              style: const TextStyle(
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

class _DrawerSection extends StatelessWidget {
  final String label;
  const _DrawerSection({required this.label});

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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
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

class _DrawerLogoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => LogoutConfirmationDialog.show(context),
      ),
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(String) onNavigate;
  final void Function(int) onSwitchTab;

  const _BottomNav({
    required this.currentIndex,
    required this.onNavigate,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                active: currentIndex == 0,
                onTap: () => onSwitchTab(0),
              ),
              _NavItem(
                icon: Icons.event_available_rounded,
                label: 'Appointments',
                active: currentIndex == 1,
                onTap: () => onSwitchTab(1),
              ),
              _NavItem(
                icon: Icons.monitor_heart_rounded,
                label: 'Health',
                active: currentIndex == 2,
                onTap: () => onSwitchTab(2),
              ),
              _NavItem(
                icon: Icons.alarm_rounded,
                label: 'Reminders',
                active: currentIndex == 3,
                onTap: () => onSwitchTab(3),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                active: currentIndex == 4,
                onTap: () => onSwitchTab(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final void Function(String route) onNavigate;
  final String userName;

  const _DashboardView({required this.onNavigate, required this.userName});

  @override
  Widget build(BuildContext context) {
    final familyService = context.watch<FamilyService>();
    final activeMember = familyService.activeMember;
    final cards = [
      (
        'Book Appointment',
        'Schedule barangay visits',
        Icons.event_available_rounded,
        BookAppointmentScreen.routeName,
      ),
      (
        'Appointment History',
        'Past and upcoming visits',
        Icons.history_rounded,
        AppointmentHistoryScreen.routeName,
      ),
      (
        'Health Reminders',
        'Stay on top of meds',
        Icons.alarm_rounded,
        RemindersScreen.routeName,
      ),
      (
        'Health Education',
        'Guides & community tips',
        Icons.menu_book_rounded,
        HealthEducationScreen.routeName,
      ),
      (
        'Health Tracking',
        'Monitor vitals quickly',
        Icons.monitor_heart_rounded,
        HealthTrackingScreen.routeName,
      ),
      (
        'Profile',
        'Manage your account',
        Icons.person_rounded,
        ProfileScreen.routeName,
      ),
      (
        'Family Monitoring',
        'Dependents & profiles',
        Icons.group_rounded,
        FamilyManagementScreen.routeName,
      ),
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF0C1F35),
                        Color(0xFF0A1629),
                        Color(0xFF0B253A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : AppColors.heroGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.08 : 0.22),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
                  blurRadius: 26,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    ProfileSwitcherScreen.routeName,
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isDark ? 0.06 : 0.22),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              isDark ? 0.12 : 0.25,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeMember?.name ?? 'Primary Account Holder',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                activeMember?.relationship ??
                                    'Tap to switch profile',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.82),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.favorite, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Healthy Barangay',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Welcome, $userName',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Book consultations, track vitals, and stay updated with barangay health reminders.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          onNavigate(BookAppointmentScreen.routeName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.event_available_rounded),
                      label: const Text('Book now'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => onNavigate(RemindersScreen.routeName),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.55)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.alarm_rounded),
                      label: const Text('View reminders'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _HighlightPill(
                      icon: Icons.shield_moon_rounded,
                      label: 'Secure & private',
                      color: Colors.white.withOpacity(0.12),
                    ),
                    const SizedBox(width: 10),
                    _HighlightPill(
                      icon: Icons.bolt_rounded,
                      label: 'Fast access',
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.95,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              final item = cards[index];
              return DashboardCard(
                title: item.$1,
                subtitle: item.$2,
                icon: item.$3,
                onTap: () => onNavigate(item.$4),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HighlightPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HighlightPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
