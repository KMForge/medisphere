import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<AppointmentModel>> fetchAppointments(String memberId) async {
    if (_userId == null) return [];
    final data = await _client
        .from('appointments')
        .select()
        .eq('user_id', _userId!)
        .eq('member_id', memberId)
        .order('date_time', ascending: false);
    return data.map((a) => AppointmentModel.fromJson(a)).toList();
  }

  Future<List<AppointmentModel>> fetchAllAppointments() async {
    final data = await _client
        .from('appointments')
        .select()
        .order('date_time', ascending: false);
    return data.map((a) => AppointmentModel.fromJson(a)).toList();
  }

  Future<List<AppointmentModel>> fetchPendingAppointments() async {
    final data = await _client
        .from('appointments')
        .select()
        .eq('status', 'scheduled')
        .order('date_time', ascending: true);
    return data.map((a) => AppointmentModel.fromJson(a)).toList();
  }

  Future<AppointmentModel> bookAppointment({
    required String memberId,
    required DateTime dateTime,
    required String service,
    required String notes,
  }) async {
    final data = await _client
        .from('appointments')
        .insert({
          'user_id': _userId,
          'member_id': memberId,
          'date_time': dateTime.toIso8601String(),
          'service': service,
          'notes': notes,
          'status': 'scheduled',
        })
        .select()
        .single();
    return AppointmentModel.fromJson(data);
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    await _client
        .from('appointments')
        .update({'status': status.name})
        .eq('id', appointmentId);
  }
}
