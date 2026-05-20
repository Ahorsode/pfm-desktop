import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final url = 'https://ufawukwbfnhvjwvmqeuo.supabase.co';
  final anonKey = 'sb_publishable_g6ON3VqsL7LBHlOyC2q1ig_42bP64_u';
  final supabase = SupabaseClient(url, anonKey);

  print("=== Fetching schemas ===");
  try {
    final response = await supabase
        .from('batches')
        .select('farm_id, id')
        .limit(1);
    print("Batches farm_id type: ${response.first['farm_id'].runtimeType}");
  } catch (e) {
    print("Error: $e");
  }

  try {
    final response = await supabase
        .from('inventory')
        .select('farm_id, farmId, id') // trying both cases to see what works
        .limit(1);
    print("Inventory response: $response");
  } catch (e) {
    print("Error: $e");
  }
  
  exit(0);
}
