import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final url = 'https://ufawukwbfnhvjwvmqeuo.supabase.co';
  final anonKey = 'sb_publishable_g6ON3VqsL7LBHlOyC2q1ig_42bP64_u';

  final supabase = SupabaseClient(url, anonKey);

  print("=== Fetching most recent 10 audit_logs ===");
  try {
    final response = await supabase
        .from('audit_logs')
        .select('*')
        .order('created_at', ascending: false)
        .limit(10);
    print("Success! Count: ${response.length}");
    for (var r in response) {
      print("  [${r['created_at']}] table: ${r['table_name']}, attr: ${r['attribute_name']}, old: ${r['old_value']}, new: ${r['new_value']}, record_id: ${r['record_id']}, farm_id: ${r['farm_id']}, user_id: ${r['user_id']}");
    }
  } catch (e) {
    print("Error: $e");
  }

  print("\n=== Fetching most recent 5 insert_logs ===");
  try {
    final response = await supabase
        .from('insert_logs')
        .select('*')
        .order('inserted_at', ascending: false)
        .limit(5);
    print("Success! Count: ${response.length}");
    for (var r in response) {
      print("  [${r['inserted_at']}] table: ${r['target_table']}, record_id: ${r['record_id']}, farm_id: ${r['farm_id']}, user_id: ${r['user_id']}");
    }
  } catch (e) {
    print("Error: $e");
  }

  print("\n=== Fetching most recent 5 delete_logs ===");
  try {
    final response = await supabase
        .from('delete_logs')
        .select('id, table_name, deleted_at, farm_id')
        .order('deleted_at', ascending: false)
        .limit(5);
    print("Success! Count: ${response.length}");
    for (var r in response) {
      print("  [${r['deleted_at']}] table: ${r['table_name']}, farm_id: ${r['farm_id']}");
    }
  } catch (e) {
    print("Error: $e");
  }

  exit(0);
}
