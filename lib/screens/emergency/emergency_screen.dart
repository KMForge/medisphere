import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/emergency_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/emergency_service.dart';
import '../../widgets/emergency_hotline_card.dart';
import '../home/home_screen.dart';

class EmergencyScreen extends StatefulWidget {
  static const String routeName = '/emergency';

  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  static const Color _emergencyRed = Color(0xFFD32F2F);
  final List<(String, String)> _hotlines = const [
    ('Barangay Health Center', '02 555 1234'),
    ('Municipal Hospital', '02 888 0000'),
    ('Ambulance', '911'),
    ('Police', '166'),
    ('Fire Station', '160'),
  ];

  final EmergencyService _service = EmergencyService();

  Timer? _timer;
  int _secondsLeft = 5;
  bool _completed = false;
  String? _emergencyType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_emergencyType != null) return;
    _emergencyType = ModalRoute.of(context)?.settings.arguments as String?;
    _startSafetyTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  EmergencyRequest _buildRequest() {
    final user = AuthService.instance.currentUser;
    final supabaseUserId =
        Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    return EmergencyRequest(
      userId: supabaseUserId,
      userName: user?.fullName ?? 'Guest User',
      contactNumber: user?.phone ?? 'Not provided',
      emergencyType: _emergencyType ?? 'Unspecified',
      timestamp: DateTime.now(),
      location: 'To be provided',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Assistance')),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? LinearGradient(
                  colors: [const Color(0xFF0F172A), const Color(0xFF1F2937)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : LinearGradient(
                  colors: [Colors.white, _emergencyRed.withOpacity(0.04)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _emergencyRed.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emergency_outlined,
                          color: _emergencyRed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sending in $_secondsLeft s',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap cancel if this was accidental. A request will be queued after the timer ends.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.75),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _cancelRequest,
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hotline Numbers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: _hotlines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final hotline = _hotlines[index];
                      return EmergencyHotlineCard(
                        name: hotline.$1,
                        phoneNumber: hotline.$2,
                        onCall: () => _simulateCall(hotline.$1, hotline.$2),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _emergencyRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _completed
                        ? null
                        : () async {
                            try {
                              await _service.sendEmergencyRequest(
                                _buildRequest(),
                              );
                              _completeFlow();
                            } catch (e) {
                              debugPrint('[EmergencyScreen] Send error: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to send: $e'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Send request now'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startSafetyTimer() {
    // Safety window allows user to cancel accidental taps before sending.
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        _completeFlow(autoSend: true);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  void _cancelRequest() {
    _timer?.cancel();
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _completeFlow({bool autoSend = false}) async {
    if (_completed) return;
    _timer?.cancel();
    setState(() => _completed = true);

    String? errorMsg;
    if (autoSend) {
      try {
        await _service.sendEmergencyRequest(_buildRequest());
        debugPrint('[EmergencyScreen] Request sent successfully (auto)');
      } catch (e) {
        debugPrint('[EmergencyScreen] Failed to send request: $e');
        errorMsg = e.toString();
      }
    }

    if (!mounted) return;

    if (errorMsg != null) {
      // Reset so user can try again
      setState(() => _completed = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send request: $errorMsg'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Request Sent'),
          content: const Text(
            'Emergency request sent successfully.\nBarangay health workers have been notified.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  (route) =>
                      route.settings.name == HomeScreen.routeName ||
                      route.isFirst,
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _simulateCall(String name, String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling $name at $number (simulation)')),
    );
  }
}
