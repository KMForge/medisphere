import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  final _client = Supabase.instance.client;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<String?> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _fetchProfile(response.user!.id);
        return null;
      }
      return 'Login failed. Please try again.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
    int? age,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'username': username},
      );
      if (response.user != null) {
        final updates = <String, dynamic>{};
        if (age != null) updates['age'] = age;
        if (phone != null && phone.isNotEmpty) updates['phone'] = phone;
        if (updates.isNotEmpty) {
          await _client
              .from('profiles')
              .update(updates)
              .eq('id', response.user!.id);
        }
        await _fetchProfile(response.user!.id);
        return null;
      }
      return 'Sign up failed. Please try again.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _fetchProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      _currentUser = UserModel.fromJson(data);
      debugPrint(
        '[AuthService] Profile loaded: ${_currentUser?.fullName}, role: ${_currentUser?.role}',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('[AuthService] _fetchProfile error: $e');
    }
  }

  Future<void> loadCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user != null) await _fetchProfile(user.id);
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? role,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    final updates = <String, dynamic>{};
    if (fullName != null && fullName.trim().isNotEmpty) {
      updates['full_name'] = fullName.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      updates['email'] = email.trim();
    }
    if (role != null && role.trim().isNotEmpty) updates['role'] = role.trim();
    if (updates.isEmpty) return;
    await _client.from('profiles').update(updates).eq('id', userId);
    await _fetchProfile(userId);
  }

  bool get isAdmin => _currentUser?.role == 'Barangay Health Admin';
  bool get isStaff => _currentUser?.role == 'Barangay Staff';
  bool get isUser => !isAdmin && !isStaff;

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final data = await _client
        .from('profiles')
        .select()
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _client.from('profiles').update({'role': role}).eq('id', userId);
  }

  Future<String?> adminCreateUser({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String role,
    int? age,
    String? phone,
  }) async {
    try {
      // Create user via public signup
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'username': username},
      );
      if (response.user != null) {
        // Wait a moment for trigger to finish, then override role
        await Future.delayed(const Duration(milliseconds: 300));
        await _client
            .from('profiles')
            .update({'role': role})
            .eq('id', response.user!.id);
        final updates = <String, dynamic>{};
        if (age != null) updates['age'] = age;
        if (phone != null && phone.isNotEmpty) updates['phone'] = phone;
        if (updates.isNotEmpty) {
          await _client
              .from('profiles')
              .update(updates)
              .eq('id', response.user!.id);
        }
        return null;
      }
      return 'Failed to create user.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
