import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import '../../services/family_service.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  static const String routeName = '/appointment-history';

  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  final _service = AppointmentService();
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final memberId = context.read<FamilyService>().activeMember?.memberId;
    if (memberId == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    final data = await _service.fetchAppointments(memberId);
    if (mounted) {
      setState(() {
        _appointments = data;
        _isLoading = false;
      });
    }
  }

  Color _statusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.redAccent;
      case AppointmentStatus.confirmed:
        return Colors.teal;
      case AppointmentStatus.scheduled:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
          ? const Center(child: Text('No appointments found.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _appointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                appointment.status,
                              ).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              appointment.status.name.toUpperCase(),
                              style: TextStyle(
                                color: _statusColor(appointment.status),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            appointment.id.length > 8
                                ? appointment.id.substring(0, 8).toUpperCase()
                                : appointment.id,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appointment.service,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${appointment.dateTime.month}/${appointment.dateTime.day}/${appointment.dateTime.year} · ${TimeOfDay.fromDateTime(appointment.dateTime).format(context)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appointment.notes,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.85),
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
