import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/id_utils.dart';

class ActivationService {
  /// Dedicated client without persisted auth — activation must use the anon role.
  /// A stale OAuth session in secure storage would otherwise query as `authenticated`,
  /// which had no matching RLS policy and returned zero rows.
  final SupabaseClient _supabase;

  ActivationService({SupabaseClient? client})
    : _supabase = client ?? _anonOnlyClient();

  static SupabaseClient _anonOnlyClient() {
    final url = dotenv.env['SUPABASE_URL']?.trim();
    final anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim();
    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env for terminal activation.',
      );
    }
    return SupabaseClient(url, anonKey);
  }

  Future<bool> activateDeviceDirectly({
    required String farmId,
    required String licenseKey,
    required String hardwareId,
  }) async {
    final result = await verifyActivationKey(
      farmId: farmId,
      activationKey: licenseKey,
      hardwareId: hardwareId,
    );
    return result == null;
  }

  /// Returns `null` when activation key is valid; otherwise returns an error.
  Future<String?> verifyActivationKey({
    required String farmId,
    required String activationKey,
    required String hardwareId,
  }) async {
    final farmFilter = farmId.trim();
    final keyFilter = activationKey.trim();
    final hardware = hardwareId.trim().isEmpty
        ? 'unknown_device'
        : hardwareId.trim();

    if (farmFilter.isEmpty || keyFilter.isEmpty) {
      return 'Farm ID and Activation Key are required.';
    }

    // Cloud HatchLog schema (May 2026): farm_id + licenseKey + hardware_id.
    final schemas = <({String farmCol, String keyCol, String hwCol})>[
      (farmCol: 'farm_id', keyCol: 'licenseKey', hwCol: 'hardware_id'),
      (farmCol: 'farm_id', keyCol: 'license_key', hwCol: 'hardware_id'),
      (farmCol: 'farm_id', keyCol: 'activation_key', hwCol: 'hardware_id'),
      (farmCol: 'farm_id', keyCol: 'desktop_license_key', hwCol: 'device_id'),
      (farmCol: 'farmId', keyCol: 'licenseKey', hwCol: 'hardwareId'),
      (farmCol: 'farmId', keyCol: 'activationKey', hwCol: 'hardwareId'),
      (farmCol: 'farmId', keyCol: 'desktopLicenseKey', hwCol: 'deviceId'),
    ];

    Map<String, dynamic>? matchedRecord;
    ({String farmCol, String keyCol, String hwCol})? matchedSchema;
    bool schemaReached = false;
    String? lastLookupError;

    for (final s in schemas) {
      try {
        final record = await _supabase
            .from('device_registrations')
            .select('id')
            .eq(s.farmCol, farmFilter)
            .eq(s.keyCol, keyFilter)
            .maybeSingle();

        schemaReached = true;
        if (record != null) {
          matchedRecord = record;
          matchedSchema = s;
          break;
        }
      } on PostgrestException catch (error, st) {
        final msg = error.message.toLowerCase();
        final isSchemaMiss =
            msg.contains('column') && msg.contains('does not exist');
        if (isSchemaMiss) continue;
        lastLookupError = error.message;
        debugPrint('Activation lookup failed: ${error.message}\n$st');
      } catch (e, st) {
        lastLookupError = e.toString();
        debugPrint('Activation lookup unexpected error: $e\n$st');
      }
    }

    if (!schemaReached) {
      if (lastLookupError != null && lastLookupError.isNotEmpty) {
        return 'Activation service unavailable: $lastLookupError';
      }
      return 'Activation service unavailable. Please try again later.';
    }

    if (matchedRecord == null || matchedSchema == null) {
      return 'Activation failed. Invalid Farm ID or Activation Key.';
    }

    try {
      await _supabase
          .from('device_registrations')
          .update({matchedSchema.hwCol: hardware})
          .eq('id', safeIdString(matchedRecord['id']));
    } catch (e, st) {
      debugPrint('Activation hardware stamp warning: $e\n$st');
    }

    return null;
  }
}
