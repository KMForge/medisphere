import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/family_member_model.dart';
import '../../services/family_service.dart';

class EditFamilyMemberScreen extends StatefulWidget {
  static const String routeName = '/family/edit';

  final FamilyMemberModel member;

  const EditFamilyMemberScreen({super.key, required this.member});

  @override
  State<EditFamilyMemberScreen> createState() => _EditFamilyMemberScreenState();
}

class _EditFamilyMemberScreenState extends State<EditFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _conditionsController;
  late String _relationship;
  late String _gender;
  String? _bloodType;
  late DateTime _dob;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _conditionsController = TextEditingController(
      text: widget.member.conditions ?? '',
    );
    _relationship = widget.member.relationship;
    _gender = widget.member.gender;
    _bloodType = widget.member.bloodType;
    _dob = widget.member.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Family Member')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _relationship,
                  decoration: const InputDecoration(labelText: 'Relationship'),
                  items:
                      const [
                            'Self',
                            'Spouse',
                            'Child',
                            'Parent',
                            'Grandparent',
                            'Sibling',
                            'Other',
                          ]
                          .map(
                            (rel) =>
                                DropdownMenuItem(value: rel, child: Text(rel)),
                          )
                          .toList(),
                  onChanged: (value) =>
                      setState(() => _relationship = value ?? _relationship),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: const ['Male', 'Female', 'Prefer not to say']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _gender = value ?? _gender),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _bloodType,
                  decoration: const InputDecoration(
                    labelText: 'Blood Type (optional)',
                  ),
                  items:
                      const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                          .map(
                            (b) => DropdownMenuItem(value: b, child: Text(b)),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _bloodType = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: _formatDate(_dob),
                    suffixIcon: const Icon(Icons.calendar_today_rounded),
                  ),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _conditionsController,
                  decoration: const InputDecoration(
                    labelText: 'Existing Conditions (optional)',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = widget.member.copyWith(
      name: _nameController.text.trim(),
      relationship: _relationship,
      gender: _gender,
      bloodType: _bloodType,
      conditions: _conditionsController.text.trim().isEmpty
          ? null
          : _conditionsController.text.trim(),
      dateOfBirth: _dob,
    );
    await context.read<FamilyService>().updateMember(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Family member updated')));
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
