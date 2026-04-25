import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class EmergencyHotlineCard extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final VoidCallback onCall;

  const EmergencyHotlineCard({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onCall,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phoneNumber,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Call $name',
                onPressed: onCall,
                icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
