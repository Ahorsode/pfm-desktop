import 'dart:async';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../data/local_db.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';

/// All possible license states the app can be in at boot time.
enum LicenseStatus {
  /// First ever launch – no install record found.
  firstLaunch,

  /// License is valid (CLOUD, OFFLINE within 30 days, or GRACE_PERIOD).
  valid,

  /// GRACE_PERIOD mode – valid but shows a grace banner.
  gracePeriod,

  /// Offline trial has passed the 30-day limit (or LOCKED in DB).
  expired,

  /// System clock was rolled back past `last_used` – fraud lockdown.
  clockTampered,
}

/// Tables that carry a `farm_id` column and need to be cascade-updated
/// when a local farm_id is overwritten by the cloud web_farm_id.
const _farmIdChildTables = [
  'batches',
  'inventory',
  'daily_feeding_logs',
  'egg_production',
  'mortality',
  'houses',
  'customers',
  'farm_settings',
  'weight_records',
  'device_registrations',
  'farm_members',
  'feed_formulations',
  'vaccination_schedules',
  'medication_schedules',
  'sales',
  'expenses',
  'settlements',
  'pending_deletions',
  'stock_logs',
  'license_configs',
];

/// Single source of truth for all licensing operations.
class LicenseService {
  final AppDatabase _db;

  LicenseService(this._db);

  // ─────────────────────────────────────────────────────────────────────────
  // BOOT CHECK
  // ─────────────────────────────────────────────────────────────────────────

  /// Called once on every app boot inside LicenseGate.
  /// Returns the current [LicenseStatus] and, as a side-effect, runs the
  /// anti-clock-tamper check.
  Future<LicenseStatus> checkLicense() async {
    final config = await _loadConfig();

    // No row → first ever launch
    if (config == null) return LicenseStatus.firstLaunch;

    // ── Anti-clock-tamper ──────────────────────────────────────────────────
    // If the wall clock is BEFORE the last recorded write, the user has
    // rolled the system clock backwards.
    final now = DateTime.now();
    if (now.isBefore(config.lastUsed.subtract(const Duration(minutes: 2)))) {
      // 2-minute grace for NTP drift
      debugPrint(
        '[License] CLOCK TAMPER: now=$now lastUsed=${config.lastUsed}',
      );
      return LicenseStatus.clockTampered;
    }

    // ── Expiry check ───────────────────────────────────────────────────────
    if (now.isAfter(config.expiresAt)) {
      // Mark as LOCKED in the DB so we don't recalculate each time
      await _setMode('LOCKED');
      return LicenseStatus.expired;
    }

    // ── Grace period ───────────────────────────────────────────────────────
    if (config.mode == 'GRACE_PERIOD') return LicenseStatus.gracePeriod;

    return LicenseStatus.valid;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OPTION 1 – CLOUD HANDSHAKE
  // ─────────────────────────────────────────────────────────────────────────

  /// Authenticates against Supabase, registers the hardware ID, reads the
  /// `expires_at` from the server and persists a CLOUD license row locally.
  ///
  /// Returns `null` on success, or an error string to display.
  Future<String?> initCloudLicense({
    required String email,
    required String password,
    required String hardwareId,
  }) async {
    try {
      // 1. Supabase sign-in
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) return 'Authentication failed. Check your credentials.';

      // 2. Fetch the web farm_id for this user
      final farmRow = await Supabase.instance.client
          .from('farms')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      final webFarmId = farmRow?['id'] as String?;

      // 3. Upsert the device registration on Supabase, get expires_at
      DateTime expiresAt;
      try {
        final regResult = await Supabase.instance.client
            .from('device_registrations')
            .upsert({
              'user_id': user.id,
              'farm_id': ?webFarmId,
              'hardware_id': hardwareId,
              'registered_at': DateTime.now().toIso8601String(),
            }, onConflict: 'hardware_id')
            .select('expires_at')
            .maybeSingle();

        final raw = regResult?['expires_at'];
        expiresAt = raw != null
            ? DateTime.parse(raw.toString())
            : DateTime.now().add(const Duration(days: 30));
      } catch (_) {
        // If registration fails (e.g. no internet after auth), default 30 days
        expiresAt = DateTime.now().add(const Duration(days: 30));
      }

      // 4. Persist license config locally
      await _upsertConfig(
        mode: 'CLOUD',
        farmId: webFarmId,
        userId: user.id,
        hardwareId: hardwareId,
        installedAt: DateTime.now(),
        expiresAt: expiresAt,
      );

      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Cloud handshake failed: $e';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OPTION 2 – OFFLINE TRIAL
  // ─────────────────────────────────────────────────────────────────────────

  /// Records the current timestamp as the installation benchmark and grants
  /// 30 days of unhindered offline access.
  Future<void> initOfflineLicense() async {
    final now = DateTime.now();
    await _upsertConfig(
      mode: 'PURE_OFFLINE',
      farmId: FarmUtils.localGenesisFarmId,
      userId: null,
      hardwareId: null,
      installedAt: now,
      expiresAt: now.add(const Duration(days: 30)),
    );
  }

  /// Bootstraps license state for desktop activation-key onboarding.
  /// This does not require web email/password authentication.
  Future<void> initCloudLicenseFromActivation({
    required String farmId,
    required String hardwareId,
  }) async {
    final now = DateTime.now();
    await _upsertConfig(
      mode: 'CLOUD',
      farmId: farmId.trim().isEmpty ? null : farmId.trim(),
      userId: null,
      hardwareId: hardwareId.trim().isEmpty ? null : hardwareId.trim(),
      installedAt: now,
      expiresAt: now.add(const Duration(days: 30)),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VOLUNTARY MID-TRIAL CLOUD MIGRATION
  // ─────────────────────────────────────────────────────────────────────────

  @visibleForTesting
  Future<Map<String, dynamic>?> fetchSupabaseFarmAndUser({
    required String email,
    required String password,
  }) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) return null;

    final farmRow = await Supabase.instance.client
        .from('farms')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();

    return {'userId': user.id, 'webFarmId': farmRow?['id'] as String?};
  }

  @visibleForTesting
  Future<void> registerDeviceOnSupabase({
    required String userId,
    required String? webFarmId,
    required String hardwareId,
  }) async {
    await Supabase.instance.client.from('device_registrations').upsert({
      'user_id': userId,
      'farm_id': ?webFarmId,
      'hardware_id': hardwareId,
      'registered_at': DateTime.now().toIso8601String(),
    }, onConflict: 'hardware_id');
  }

  /// Links an existing PURE_OFFLINE trial to a cloud Supabase account.
  /// 1. Authenticates with Supabase.
  /// 2. Retrieves the user's web_farm_id from the farms table.
  /// 3. Executes the 20-table cascade update of local farm_id to web_farm_id.
  /// 4. Registers the hardware ID.
  /// 5. Updates mode to CLOUD_TRIAL, preserving the original expiration countdown.
  ///
  /// Returns null on success, or an error message.
  Future<String?> linkCloudAccount({
    required String email,
    required String password,
    required String hardwareId,
  }) async {
    try {
      // 1 & 2. Supabase sign-in and fetch farm
      final authData = await fetchSupabaseFarmAndUser(
        email: email,
        password: password,
      );
      if (authData == null) {
        return 'Authentication failed. Check your credentials.';
      }

      final userId = authData['userId'] as String;
      final webFarmId = authData['webFarmId'] as String?;

      // 3. Read local farm_id to cascade-migrate
      final config = await _loadConfig();
      if (config == null) return 'Local license configuration not found.';
      final localFarmId = config.farmId;

      if (webFarmId != null &&
          localFarmId != null &&
          localFarmId != webFarmId) {
        await runFarmIdCascade(localFarmId: localFarmId, webFarmId: webFarmId);
      }

      // 4. Register hardware on Supabase
      try {
        await registerDeviceOnSupabase(
          userId: userId,
          webFarmId: webFarmId,
          hardwareId: hardwareId,
        );
      } catch (e) {
        debugPrint('[License] Device registration warning: $e');
      }

      // 5. Calculate remaining trial time and preserve countdown
      final remainingTime = config.expiresAt.difference(DateTime.now());
      debugPrint(
        '[License] Cloud link migration: remaining trial countdown is $remainingTime',
      );
      final preservedExpiry = config.expiresAt;

      // Update license config locally
      await (_db.update(
        _db.licenseConfigs,
      )..where((t) => t.id.equals('singleton'))).write(
        LicenseConfigsCompanion(
          mode: const Value('CLOUD_TRIAL'),
          farmId: Value(webFarmId ?? localFarmId),
          userId: Value(userId),
          hardwareId: Value(hardwareId),
          expiresAt: Value(preservedExpiry),
          lastUsed: Value(DateTime.now()),
        ),
      );

      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Cloud migration failed: $e';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOCKOUT RESCUE – GRACE PERIOD BRIDGE
  // ─────────────────────────────────────────────────────────────────────────

  /// Called from the LockoutScreen after the user logs in online.
  ///
  /// 1. Authenticates against Supabase.
  /// 2. Fetches `web_farm_id` from the `farms` table.
  /// 3. Runs the SQLite farm_id cascade migration.
  /// 4. Upserts hardware ID to Supabase `device_registrations`.
  /// 5. Writes a GRACE_PERIOD license with 10 extra days.
  ///
  /// Returns `null` on success or an error string.
  Future<String?> applyGracePeriod({
    required String email,
    required String password,
    required String hardwareId,
  }) async {
    try {
      // 1. Sign in
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) return 'Authentication failed.';

      // 2. Get web farm_id
      final farmRow = await Supabase.instance.client
          .from('farms')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      final webFarmId = farmRow?['id'] as String?;

      // 3. Read local farm_id to cascade-migrate
      final config = await _loadConfig();
      final localFarmId = config?.farmId;

      if (webFarmId != null &&
          localFarmId != null &&
          localFarmId != webFarmId) {
        await runFarmIdCascade(localFarmId: localFarmId, webFarmId: webFarmId);
      }

      // 4. Register hardware on Supabase
      try {
        await Supabase.instance.client.from('device_registrations').upsert({
          'user_id': user.id,
          'farm_id': ?webFarmId,
          'hardware_id': hardwareId,
          'registered_at': DateTime.now().toIso8601String(),
        }, onConflict: 'hardware_id');
      } catch (e) {
        debugPrint('[License] Grace period device registration warn: $e');
      }

      // 5. Write GRACE_PERIOD config (+10 days)
      final now = DateTime.now();
      await _upsertConfig(
        mode: 'GRACE_PERIOD',
        farmId: webFarmId ?? localFarmId,
        userId: user.id,
        hardwareId: hardwareId,
        installedAt: config?.installedAt ?? now,
        expiresAt: now.add(const Duration(days: 10)),
      );

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Grace period activation failed: $e';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECONDARY RENEWAL (subsequent cloud sync checkups)
  // ─────────────────────────────────────────────────────────────────────────

  /// On each boot (when online), silently refresh the local `expires_at`
  /// from whatever Supabase has for this hardware ID.
  /// Does NOT re-fetch or re-verify `farm_id`.
  Future<void> renewFromCloud(String hardwareId) async {
    try {
      final row = await Supabase.instance.client
          .from('device_registrations')
          .select('expires_at')
          .eq('hardware_id', hardwareId)
          .maybeSingle();

      final raw = row?['expires_at'];
      if (raw == null) return;
      final serverExpiry = DateTime.tryParse(raw.toString());
      if (serverExpiry == null) return;

      final config = await _loadConfig();
      if (config == null) return;

      // Only update if server has a later expiry than what we have locally
      if (serverExpiry.isAfter(config.expiresAt)) {
        await (_db.update(
          _db.licenseConfigs,
        )..where((t) => t.id.equals('singleton'))).write(
          LicenseConfigsCompanion(
            expiresAt: Value(serverExpiry),
            lastUsed: Value(DateTime.now()),
          ),
        );
        debugPrint('[License] Renewed expiry to $serverExpiry from cloud.');
      }
    } catch (e) {
      debugPrint('[License] Cloud renewal skipped (offline?): $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ANTI-CLOCK-TAMPER STAMP
  // ─────────────────────────────────────────────────────────────────────────

  /// Call this on every local DB write operation to keep `last_used` fresh.
  /// If the clock is later rolled back, `checkLicense()` will catch it.
  Future<void> touchLastUsed() async {
    try {
      await (_db.update(_db.licenseConfigs)
            ..where((t) => t.id.equals('singleton')))
          .write(LicenseConfigsCompanion(lastUsed: Value(DateTime.now())));
    } catch (_) {
      // Silent – license row may not exist yet on very first boot
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FARM ID CASCADE MIGRATION ENGINE
  // ─────────────────────────────────────────────────────────────────────────

  /// Rewrites `farm_id` on child tables without changing the parent `farms` row.
  Future<void> remapFarmIdReferences(String fromFarmId, String toFarmId) async {
    final from = safeIdString(fromFarmId);
    final to = safeIdString(toFarmId);
    if (from == to) return;

    for (final tableName in _farmIdChildTables) {
      await _db.customStatement(
        'UPDATE $tableName SET farm_id = ? WHERE farm_id = ?',
        [to, from],
      );
    }
  }

  /// Ensures local rows and [FarmUtils] binding use [webFarmId] before cloud sync.
  Future<void> reconcileToCloudFarmId(String webFarmId) async {
    final web = safeIdString(webFarmId);
    final bound = await FarmUtils.getBoundFarmId();
    final config = await _loadConfig();
    final configFarmId = config?.farmId?.trim();

    final localSources = <String>{
      FarmUtils.localGenesisFarmId,
      if (bound != null && bound.isNotEmpty) bound,
      if (configFarmId != null && configFarmId.isNotEmpty) configFarmId,
    }..remove(web);

    final cloudFarmExists = await (_db.select(
      _db.farms,
    )..where((f) => f.id.equals(web))).getSingleOrNull();

    for (final local in localSources) {
      final localFarm = await (_db.select(
        _db.farms,
      )..where((f) => f.id.equals(local))).getSingleOrNull();

      if (localFarm == null) {
        await remapFarmIdReferences(local, web);
        continue;
      }

      if (cloudFarmExists != null) {
        await mergeLocalFarmIntoCloud(localFarmId: local, webFarmId: web);
      } else {
        await runFarmIdCascade(localFarmId: local, webFarmId: web);
      }
      return;
    }

    await FarmUtils.setBoundFarmId(web);
  }

  /// Moves child rows from [localFarmId] to an existing cloud [webFarmId] row.
  Future<void> mergeLocalFarmIntoCloud({
    required String localFarmId,
    required String webFarmId,
  }) async {
    final local = safeIdString(localFarmId);
    final web = safeIdString(webFarmId);
    if (local == web) return;

    debugPrint(
      '[License] Merging local farm $local into existing cloud farm $web',
    );

    await _db.transaction(() async {
      await _db.customStatement('PRAGMA foreign_keys = OFF;');
      try {
        for (final tableName in _farmIdChildTables) {
          await _db.customStatement(
            'UPDATE $tableName SET farm_id = ? WHERE farm_id = ?',
            [web, local],
          );
        }
        await _db.customStatement('DELETE FROM farms WHERE id = ?', [local]);
      } finally {
        await _db.customStatement('PRAGMA foreign_keys = ON;');
      }
    });

    await FarmUtils.setBoundFarmId(web);
  }

  /// Renames the local `farms` primary key to [webFarmId] when cloud row is absent.
  Future<void> runFarmIdCascade({
    required String localFarmId,
    required String webFarmId,
  }) async {
    debugPrint('[License] Running farm_id cascade: $localFarmId → $webFarmId');

    await _db.transaction(() async {
      // Disable FK enforcement so we can rewrite the PK safely
      await _db.customStatement('PRAGMA foreign_keys = OFF;');

      try {
        // 1. Update the parent farms row (PK change)
        await _db.customStatement(
          'UPDATE farms SET id = ?, sync_status = ? WHERE id = ?',
          [webFarmId, 'CLOUD_SYNCED', localFarmId],
        );

        // 2. Cascade farm_id across all child tables
        for (final tableName in _farmIdChildTables) {
          await _db.customStatement(
            'UPDATE $tableName SET farm_id = ? WHERE farm_id = ?',
            [webFarmId, localFarmId],
          );
        }

        debugPrint('[License] Cascade complete for $localFarmId → $webFarmId');
      } finally {
        // Always re-enable FK enforcement
        await _db.customStatement('PRAGMA foreign_keys = ON;');
      }
    });

    await FarmUtils.setBoundFarmId(webFarmId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Future<LicenseConfig?> _loadConfig() async {
    return (_db.select(
      _db.licenseConfigs,
    )..where((t) => t.id.equals('singleton'))).getSingleOrNull();
  }

  Future<void> _upsertConfig({
    required String mode,
    required String? farmId,
    required String? userId,
    required String? hardwareId,
    required DateTime installedAt,
    required DateTime expiresAt,
  }) async {
    final now = DateTime.now();
    await _db
        .into(_db.licenseConfigs)
        .insertOnConflictUpdate(
          LicenseConfigsCompanion.insert(
            id: 'singleton',
            mode: Value(mode),
            farmId: Value(farmId),
            userId: Value(userId),
            hardwareId: Value(hardwareId),
            installedAt: Value(installedAt),
            expiresAt: expiresAt,
            lastUsed: Value(now),
          ),
        );
  }

  Future<void> _setMode(String mode) async {
    await (_db.update(_db.licenseConfigs)
          ..where((t) => t.id.equals('singleton')))
        .write(LicenseConfigsCompanion(mode: Value(mode)));
  }

  /// Reads the persisted license config. Exposed for UI inspection.
  Future<LicenseConfig?> getConfig() => _loadConfig();
}
