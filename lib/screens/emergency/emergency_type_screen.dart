import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'emergency_screen.dart';

class EmergencyTypeScreen extends StatefulWidget {
  static const String routeName = '/emergency/type';

  const EmergencyTypeScreen({super.key});

  @override
  State<EmergencyTypeScreen> createState() => _EmergencyTypeScreenState();
}

class _EmergencyTypeScreenState extends State<EmergencyTypeScreen> {
  final List<String> _types = const [
    'Medical Emergency',
    'Accident',
    'Pregnancy Emergency',
    'Child Emergency',
    'Other',
  ];

  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Emergency Type')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose what best describes your situation. You can skip if unsure.',
              style: Theme.of(context)
                  .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _types.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndex == index;
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFD32F2F)
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected
                            ? const Color(0xFFFFEBEE)
                            : Theme.of(context).colorScheme.surface,
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emergency_outlined,
                            color: isSelected ? const Color(0xFFD32F2F) : AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _types[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(isSelected ? 0.95 : 0.9),
                                  ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Color(0xFFD32F2F)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _goToHotlines(context, null),
                    child: const Text('Skip for now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _goToHotlines(
                      context,
                      _selectedIndex != null ? _types[_selectedIndex!] : null,
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _goToHotlines(BuildContext context, String? type) {
    Navigator.pushNamed(context, EmergencyScreen.routeName, arguments: type);
  }
}
