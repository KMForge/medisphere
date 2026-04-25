import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/health_record_model.dart';
import '../../services/family_service.dart';
import '../../services/health_record_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class HealthTrackingScreen extends StatefulWidget {
  static const String routeName = '/health-tracking';
  final bool embedded;

  const HealthTrackingScreen({super.key, this.embedded = false});

  @override
  State<HealthTrackingScreen> createState() => _HealthTrackingScreenState();
}

class _HealthTrackingScreenState extends State<HealthTrackingScreen> {
  final _bpController = TextEditingController();
  final _hrController = TextEditingController();
  final _weightController = TextEditingController();
  final _tempController = TextEditingController();
  final _recordService = HealthRecordService();
  List<HealthRecordModel> _records = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadedMemberId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final memberId = context.read<FamilyService>().activeMember?.memberId;
    if (memberId != null && memberId != _loadedMemberId) {
      _loadedMemberId = memberId;
      _loadRecords(memberId);
    }
  }

  Future<void> _loadRecords(String memberId) async {
    setState(() => _isLoading = true);
    final data = await _recordService.fetchRecords(memberId);
    if (mounted) {
      setState(() {
        _records = data;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bpController.dispose();
    _hrController.dispose();
    _weightController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  Future<void> _addRecord() async {
    if (_bpController.text.isEmpty ||
        _hrController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _tempController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }
    final activeId = context.read<FamilyService>().activeMember?.memberId;
    if (activeId == null) return;
    setState(() => _isSaving = true);
    try {
      final record = await _recordService.addRecord(
        HealthRecordModel(
          memberId: activeId,
          date: DateTime.now(),
          bloodPressure: _bpController.text.trim(),
          heartRate: int.tryParse(_hrController.text) ?? 0,
          weight: double.tryParse(_weightController.text) ?? 0,
          temperature: double.tryParse(_tempController.text) ?? 0,
        ),
      );
      setState(() {
        _records.insert(0, record);
        _bpController.clear();
        _hrController.clear();
        _weightController.clear();
        _tempController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildBody(BuildContext context) {
    final activeMember = context.watch<FamilyService>().activeMember;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _bpController,
              label: 'Blood Pressure',
              hint: 'e.g., 120/80',
              prefixIcon: const Icon(Icons.monitor_heart_rounded),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _hrController,
              label: 'Heart Rate (bpm)',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.favorite_outline),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _weightController,
              label: 'Weight (kg)',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.monitor_weight),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _tempController,
              label: 'Temperature (°C)',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.thermostat),
            ),
            const SizedBox(height: 18),
            CustomButton(
              label: _isSaving ? 'Saving...' : 'Add record',
              onPressed: _isSaving ? () {} : _addRecord,
            ),
            const SizedBox(height: 20),
            Text(
              'Recent records for ${activeMember?.name ?? 'profile'}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_records.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.08)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.75),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No records yet. Add your first vital stats above.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  final record = _records[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                            Text(
                              '${record.date.month}/${record.date.day}/${record.date.year}',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.favorite_rounded,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _Chip('BP ${record.bloodPressure}'),
                            _Chip('HR ${record.heartRate} bpm'),
                            _Chip('Wt ${record.weight.toStringAsFixed(1)} kg'),
                            _Chip(
                              'Temp ${record.temperature.toStringAsFixed(1)} °C',
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildBody(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Health Tracking')),
      body: _buildBody(context),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.secondary.withOpacity(0.18),
      labelStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
