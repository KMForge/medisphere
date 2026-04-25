import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/family_member_model.dart';
import '../../services/family_service.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  static const String routeName = '/family/add';

  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _conditionsController = TextEditingController();
  String _relationship = 'Child';
  String _gender = 'Female';
  String? _bloodType;
  DateTime? _dob;

  @override
  void dispose() {
    _nameController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Family Member')),
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
                  validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _relationship,
                  decoration: const InputDecoration(labelText: 'Relationship'),
                  items: const [
                    'Self',
                    'Spouse',
                    'Child',
                    'Parent',
                    'Grandparent',
                    'Sibling',
                    'Other',
                  ].map((rel) => DropdownMenuItem(value: rel, child: Text(rel))).toList(),
                  onChanged: (value) => setState(() => _relationship = value ?? _relationship),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: const ['Male', 'Female', 'Prefer not to say']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) => setState(() => _gender = value ?? _gender),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _bloodType,
                  decoration: const InputDecoration(labelText: 'Blood Type (optional)'),
                  items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (value) => setState(() => _bloodType = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: _dob != null ? _formatDate(_dob!) : 'Select date',
                    suffixIcon: const Icon(Icons.calendar_today_rounded),
                  ),
                  onTap: _pickDate,
                  validator: (_) => _dob == null ? 'Date of birth is required' : null,
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
                        child: const Text('Save'),
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
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final member = FamilyMemberModel(
      name: _nameController.text.trim(),
      relationship: _relationship,
      dateOfBirth: _dob!,
      gender: _gender,
      bloodType: _bloodType,
      conditions: _conditionsController.text.trim().isEmpty ? null : _conditionsController.text.trim(),
    );
    await context.read<FamilyService>().addMember(member);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Family member added')),
    );
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
