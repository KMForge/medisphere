import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/family_service.dart';
import 'package:provider/provider.dart';
import '../admin/admin_home_screen.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../staff/staff_home_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Timer(const Duration(seconds: 3), _checkSession);
  }

  Future<void> _checkSession() async {
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await AuthService.instance.loadCurrentUser();
      if (!mounted) return;
      final auth = AuthService.instance;
      if (auth.isAdmin) {
        Navigator.pushReplacementNamed(context, AdminHomeScreen.routeName);
      } else if (auth.isStaff) {
        Navigator.pushReplacementNamed(context, StaffHomeScreen.routeName);
      } else {
        await context.read<FamilyService>().loadMembers();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      }
    } else {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.heroGradient),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 120,
                  right: 40,
                  child: _AccentBlob(
                    scale: 1.1 + (_pulseScale.value - 1) * 0.3,
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: 60,
                  child: _AccentBlob(
                    scale: 0.9 + (_pulseScale.value - 1) * 0.2,
                  ),
                ),
                Center(
                  child: FadeTransition(
                    opacity: _fade,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: _pulseScale.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    colors: [
                                      Color(0x66FFFFFF),
                                      Color(0x1AFFFFFF),
                                    ],
                                    radius: 0.78,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.shadow,
                                      offset: Offset(0, 20),
                                      blurRadius: 34,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 112,
                                width: 112,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x4426A69A),
                                      blurRadius: 26,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'lib/Images/mediSphere logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'MediSphere',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Barangay Health Monitoring System',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AccentBlob extends StatelessWidget {
  final double scale;

  const _AccentBlob({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppColors.accentBlue.withOpacity(0.24),
              Colors.white.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
      ),
    );
  }
}
