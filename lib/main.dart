import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'screens/appointment/appointment_history_screen.dart';
import 'screens/appointment/book_appointment_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/emergency/emergency_screen.dart';
import 'screens/emergency/emergency_type_screen.dart';
import 'screens/family/add_family_member_screen.dart';
import 'screens/family/family_management_screen.dart';
import 'screens/family/profile_switcher_screen.dart';
import 'screens/education/health_education_screen.dart';
import 'screens/health_tracking/health_tracking_screen.dart';
import 'screens/admin/add_staff_screen.dart';
import 'screens/admin/admin_appointments_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/staff/staff_home_screen.dart';
import 'screens/reminders/reminders_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/family_service.dart';
import 'services/theme_service.dart';
import 'screens/admin/inventory_management_screen.dart';
import 'screens/admin/add_medicine_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://alhnbcouykonbljfrwxl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsaG5iY291eWtvbmJsamZyd3hsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5NzgzNzMsImV4cCI6MjA4ODU1NDM3M30.dQKv2NsrLMrWhKwlQbV4HTinE12a4ZDT7KGr6orPXGc',
  );
  runApp(const MediSphereApp());
}

class MediSphereApp extends StatelessWidget {
  const MediSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthService.instance),
        ChangeNotifierProvider(create: (_) => FamilyService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MediSphere',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.mode,
            initialRoute: SplashScreen.routeName,
            routes: {
              SplashScreen.routeName: (_) => const SplashScreen(),
              LoginScreen.routeName: (_) => const LoginScreen(),
              SignupScreen.routeName: (_) => const SignupScreen(),
              HomeScreen.routeName: (_) => const HomeScreen(),
              AdminHomeScreen.routeName: (_) => const AdminHomeScreen(),
              AdminAppointmentsScreen.routeName: (_) =>
                  const AdminAppointmentsScreen(),
              AdminUsersScreen.routeName: (_) => const AdminUsersScreen(),
              AddStaffScreen.routeName: (_) => const AddStaffScreen(),
              StaffHomeScreen.routeName: (_) => const StaffHomeScreen(),
              BookAppointmentScreen.routeName: (_) =>
                  const BookAppointmentScreen(),
              AppointmentHistoryScreen.routeName: (_) =>
                  const AppointmentHistoryScreen(),
              RemindersScreen.routeName: (_) => const RemindersScreen(),
              HealthEducationScreen.routeName: (_) =>
                  const HealthEducationScreen(),
              HealthTrackingScreen.routeName: (_) =>
                  const HealthTrackingScreen(),
              ProfileScreen.routeName: (_) => const ProfileScreen(),
              EmergencyTypeScreen.routeName: (_) => const EmergencyTypeScreen(),
              EmergencyScreen.routeName: (_) => const EmergencyScreen(),
              FamilyManagementScreen.routeName: (_) =>
                  const FamilyManagementScreen(),
              AddFamilyMemberScreen.routeName: (_) =>
                  const AddFamilyMemberScreen(),
              ProfileSwitcherScreen.routeName: (_) =>
                  const ProfileSwitcherScreen(),
              // Medicine Inventory (Admin/Staff only)
              InventoryManagementScreen.routeName: (_) =>
                  const InventoryManagementScreen(),
              AddMedicineScreen.routeName: (_) => const AddMedicineScreen(),
            },
          );
        },
      ),
    );
  }
}
