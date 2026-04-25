import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/family_service.dart';
import '../../widgets/empty_family_state.dart';
import '../../widgets/family_member_card.dart';
import 'add_family_member_screen.dart';
import 'edit_family_member_screen.dart';

class FamilyManagementScreen extends StatelessWidget {
  static const String routeName = '/family/manage';

  const FamilyManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final familyService = context.watch<FamilyService>();
    final members = familyService.members;

    return Scaffold(
      appBar: AppBar(title: const Text('Family Monitoring')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AddFamilyMemberScreen.routeName),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Member'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: members.isEmpty
              ? EmptyFamilyState(onAdd: () => Navigator.pushNamed(context, AddFamilyMemberScreen.routeName))
              : ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return FamilyMemberCard(
                      member: member,
                      isActive: member.memberId == familyService.activeMember?.memberId,
                      onTap: () => context.read<FamilyService>().switchActiveMember(member.memberId),
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditFamilyMemberScreen(member: member),
                          ),
                        );
                      },
                      onDelete: member.isPrimaryAccount
                          ? null
                          : () => _confirmDelete(context, member.memberId),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String memberId) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove family member'),
          content: const Text('Are you sure you want to remove this family member?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await context.read<FamilyService>().deleteMember(memberId);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
