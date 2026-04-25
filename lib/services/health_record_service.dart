import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/health_record_model.dart';

class HealthRecordService {
  final _client = Supabase.instance.client;

  Future<List<HealthRecordModel>> fetchRecords(String memberId) async {
    final data = await _client
        .from('health_records')
        .select()
        .eq('member_id', memberId)
        .order('date', ascending: false);
    return data.map((r) => HealthRecordModel.fromJson(r)).toList();
  }

  Future<HealthRecordModel> addRecord(HealthRecordModel record) async {
    final payload = record.toJson();
    final data = await _client
        .from('health_records')
        .insert(payload)
        .select()
        .single();
    return HealthRecordModel.fromJson(data);
  }
}
