import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class EmptyFamilyState extends StatelessWidget {
  final VoidCallback onAdd;

  const EmptyFamilyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: const Icon(Icons.group_rounded, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'No family members added yet.',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your dependents to monitor their health together.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add_alt_1_rounded),
              onPressed: onAdd,
              label: const Text('Add family member'),
            ),
          ],
        ),
      ),
    );
  }
}
