import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/family_service.dart';
import '../../widgets/family_member_card.dart';
import 'family_management_screen.dart';

class ProfileSwitcherScreen extends StatelessWidget {
  static const String routeName = '/family/switch';

  const ProfileSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final familyService = context.watch<FamilyService>();
    final members = familyService.members;
    final activeId = familyService.activeMember?.memberId;

    return Scaffold(
      appBar: AppBar(title: const Text('Switch Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: members.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final member = members[index];
                  return FamilyMemberCard(
                    member: member,
                    isActive: member.memberId == activeId,
                    onTap: () async {
                      await context.read<FamilyService>().switchActiveMember(member.memberId);
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, FamilyManagementScreen.routeName),
                icon: const Icon(Icons.manage_accounts_rounded),
                label: const Text('Manage family members'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
