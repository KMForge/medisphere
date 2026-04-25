import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reminder_model.dart';

class ReminderService {
  final _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<ReminderModel>> fetchReminders() async {
    if (_userId == null) return [];
    final data = await _client
        .from('reminders')
        .select()
        .eq('user_id', _userId!)
        .order('schedule');
    return data.map((r) => ReminderModel.fromJson(r)).toList();
  }

  Future<ReminderModel> addReminder(ReminderModel reminder) async {
    final payload = reminder.toJson();
    payload['user_id'] = _userId;
    final data = await _client
        .from('reminders')
        .insert(payload)
        .select()
        .single();
    return ReminderModel.fromJson(data);
  }

  Future<void> deleteReminder(String id) async {
    await _client.from('reminders').delete().eq('id', id);
  }
}
