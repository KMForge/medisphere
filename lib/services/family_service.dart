import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/family_member_model.dart';

class FamilyService extends ChangeNotifier {
  final _client = Supabase.instance.client;

  List<FamilyMemberModel> _members = [];
  String? _activeMemberId;
  bool _isLoading = false;

  List<FamilyMemberModel> get members => List.unmodifiable(_members);
  bool get isLoading => _isLoading;

  FamilyMemberModel? get activeMember {
    if (_members.isEmpty) return null;
    return _members.firstWhere(
      (m) => m.memberId == _activeMemberId,
      orElse: () => _members.first,
    );
  }

  String? get _userId => _client.auth.currentUser?.id;

  Future<void> loadMembers() async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _client
          .from('family_members')
          .select()
          .eq('user_id', _userId!)
          .order('created_at');
      _members = data.map((m) => FamilyMemberModel.fromJson(m)).toList();
      if (_members.isNotEmpty && _activeMemberId == null) {
        _activeMemberId = _members.first.memberId;
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMember(FamilyMemberModel member) async {
    if (_userId == null) return;
    final payload = member.toJson();
    payload['user_id'] = _userId;
    final result = await _client
        .from('family_members')
        .insert(payload)
        .select()
        .single();
    _members.add(FamilyMemberModel.fromJson(result));
    _activeMemberId ??= _members.first.memberId;
    notifyListeners();
  }

  Future<void> updateMember(FamilyMemberModel updated) async {
    final index = _members.indexWhere((m) => m.memberId == updated.memberId);
    if (index == -1) return;
    final existing = _members[index];
    final toSave = updated.copyWith(
      isPrimaryAccount: existing.isPrimaryAccount,
    );
    await _client
        .from('family_members')
        .update(toSave.toJson())
        .eq('id', updated.memberId);
    _members[index] = toSave;
    notifyListeners();
  }

  Future<void> deleteMember(String memberId) async {
    final member = _members.firstWhere((m) => m.memberId == memberId);
    if (member.isPrimaryAccount) return;
    await _client.from('family_members').delete().eq('id', memberId);
    _members.removeWhere((m) => m.memberId == memberId);
    if (_activeMemberId == memberId) {
      _activeMemberId = _members.isNotEmpty ? _members.first.memberId : null;
    }
    notifyListeners();
  }

  Future<void> switchActiveMember(String memberId) async {
    _activeMemberId = memberId;
    notifyListeners();
  }

  List<FamilyMemberModel> getAllMembers() => List.unmodifiable(_members);
}
