import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/emergency_model.dart';

class EmergencyService {
  final _client = Supabase.instance.client;

  Future<void> sendEmergencyRequest(EmergencyRequest request) async {
    await _client.from('emergency_requests').insert(request.toJson());
  }

  Future<List<EmergencyRequest>> fetchEmergencyHistory() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final data = await _client
        .from('emergency_requests')
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false);
    return data.map((e) => EmergencyRequest.fromJson(e)).toList();
  }

  Future<EmergencyRequest> updateEmergencyStatus(
    String requestId,
    EmergencyStatus status,
  ) async {
    final data = await _client
        .from('emergency_requests')
        .update({'status': status.name})
        .eq('id', requestId)
        .select()
        .single();
    return EmergencyRequest.fromJson(data);
  }
}
