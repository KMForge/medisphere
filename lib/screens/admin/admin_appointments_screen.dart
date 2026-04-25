import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  static const String routeName = '/admin-appointments';
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  final _service = AppointmentService();
  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> _filtered = [];
  bool _loading = true;
  String _filter = 'All';

  static const _filters = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _service.fetchAllAppointments();
    setState(() {
      _appointments = data;
      _applyFilter(_filter);
      _loading = false;
    });
  }

  void _applyFilter(String f) {
    _filter = f;
    _filtered = f == 'All'
        ? List.from(_appointments)
        : _appointments.where((a) {
            switch (f) {
              case 'Pending':
                return a.status == AppointmentStatus.scheduled;
              case 'Confirmed':
                return a.status == AppointmentStatus.confirmed;
              case 'Completed':
                return a.status == AppointmentStatus.completed;
              case 'Cancelled':
                return a.status == AppointmentStatus.cancelled;
              default:
                return true;
            }
          }).toList();
  }

  Future<void> _updateStatus(AppointmentModel appt, AppointmentStatus status) async {
    await _service.updateAppointmentStatus(appt.id, status);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appointment ${status.name}.'),
        backgroundColor: _statusColor(status),
      ),
    );
  }

  Color _statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed:
        return Colors.teal;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.redAccent;
      case AppointmentStatus.scheduled:
        return AppColors.primary;
    }
  }

  String _statusLabel(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.scheduled:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _filters[i];
                final active = _filter == f;
                return ChoiceChip(
                  label: Text(f),
                  selected: active,
                  onSelected: (_) => setState(() => _applyFilter(f)),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: active ? Colors.white : null,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_busy_rounded,
                                size: 56, color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              'No $_filter appointments',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) =>
                              _AppointmentCard(
                            appointment: _filtered[i],
                            statusColor: _statusColor(_filtered[i].status),
                            statusLabel: _statusLabel(_filtered[i].status),
                            onConfirm: _filtered[i].status ==
                                    AppointmentStatus.scheduled
                                ? () => _updateStatus(
                                    _filtered[i], AppointmentStatus.confirmed)
                                : null,
                            onComplete: _filtered[i].status ==
                                    AppointmentStatus.confirmed
                                ? () => _updateStatus(
                                    _filtered[i], AppointmentStatus.completed)
                                : null,
                            onCancel: (_filtered[i].status ==
                                        AppointmentStatus.scheduled ||
                                    _filtered[i].status ==
                                        AppointmentStatus.confirmed)
                                ? () => _updateStatus(
                                    _filtered[i], AppointmentStatus.cancelled)
                                : null,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const _AppointmentCard({
    required this.appointment,
    required this.statusColor,
    required this.statusLabel,
    this.onConfirm,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dt = appointment.dateTime;
    final dateStr =
        '${dt.month}/${dt.day}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.2),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 6)),
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
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.event_available_rounded,
                    color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.service,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      dateStr,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (appointment.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Notes: ${appointment.notes}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          if (onConfirm != null || onComplete != null || onCancel != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                if (onConfirm != null)
                  Expanded(
                    child: _ActionButton(
                      label: 'Confirm',
                      icon: Icons.check_circle_outline_rounded,
                      color: Colors.teal,
                      onTap: onConfirm!,
                    ),
                  ),
                if (onConfirm != null && onCancel != null)
                  const SizedBox(width: 8),
                if (onComplete != null)
                  Expanded(
                    child: _ActionButton(
                      label: 'Complete',
                      icon: Icons.task_alt_rounded,
                      color: Colors.green,
                      onTap: onComplete!,
                    ),
                  ),
                if (onComplete != null && onCancel != null)
                  const SizedBox(width: 8),
                if (onCancel != null)
                  Expanded(
                    child: _ActionButton(
                      label: 'Cancel',
                      icon: Icons.cancel_outlined,
                      color: Colors.redAccent,
                      onTap: onCancel!,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
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
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
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
