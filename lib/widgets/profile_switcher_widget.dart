import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../services/family_service.dart';
import '../screens/family/profile_switcher_screen.dart';

class ProfileSwitcherWidget extends StatelessWidget {
  const ProfileSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final familyService = context.watch<FamilyService>();
    final active = familyService.activeMember;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ProfileSwitcherScreen.routeName),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: Text(
                active?.name.isNotEmpty == true ? active!.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    active?.name ?? 'Select profile',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    active?.relationship ?? 'Tap to switch profile',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
            ),
          ],
        ),
      ),
    );
  }
}
