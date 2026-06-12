import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/data/local_db.dart';
import 'package:poultry_pms_desktop/services/license_service.dart';
import 'package:poultry_pms_desktop/utils/farm_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late LicenseService licenseService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    licenseService = LicenseService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('checkLicense returns firstLaunch when empty', () async {
    final status = await licenseService.checkLicense();
    expect(status, LicenseStatus.firstLaunch);
  });

  test('initOfflineLicense creates valid trial license config', () async {
    await licenseService.initOfflineLicense();

    final config = await licenseService.getConfig();
    expect(config, isNotNull);
    expect(config!.id, 'singleton');
    expect(config.mode, 'PURE_OFFLINE');
    expect(config.farmId, FarmUtils.localGenesisFarmId);
    expect(config.userId, isNull);
    expect(config.hardwareId, isNull);
    expect(config.expiresAt.difference(config.installedAt).inDays, 30);

    final status = await licenseService.checkLicense();
    expect(status, LicenseStatus.valid);
  });

  test('touchLastUsed updates lastUsed timestamp', () async {
    await licenseService.initOfflineLicense();

    // Explicitly set lastUsed to 10 seconds in the past
    final pastTime = DateTime.now().subtract(const Duration(seconds: 10));
    await (db.update(db.licenseConfigs)..where((t) => t.id.equals('singleton')))
        .write(LicenseConfigsCompanion(lastUsed: Value(pastTime)));

    await licenseService.touchLastUsed();

    final newConfig = await licenseService.getConfig();
    expect(newConfig!.lastUsed.isAfter(pastTime), isTrue);
  });

  test(
    'checkLicense returns clockTampered when system clock is rolled back',
    () async {
      await licenseService.initOfflineLicense();

      // Directly update lastUsed to the future in DB to simulate clock rollback
      final futureTime = DateTime.now().add(const Duration(minutes: 10));
      await (db.update(db.licenseConfigs)
            ..where((t) => t.id.equals('singleton')))
          .write(LicenseConfigsCompanion(lastUsed: Value(futureTime)));

      final status = await licenseService.checkLicense();
      expect(status, LicenseStatus.clockTampered);
    },
  );

  test(
    'checkLicense returns expired when expired and sets mode to LOCKED',
    () async {
      await licenseService.initOfflineLicense();

      // Directly update expiresAt to the past in DB
      final pastTime = DateTime.now().subtract(const Duration(seconds: 1));
      await (db.update(db.licenseConfigs)
            ..where((t) => t.id.equals('singleton')))
          .write(LicenseConfigsCompanion(expiresAt: Value(pastTime)));

      final status = await licenseService.checkLicense();
      expect(status, LicenseStatus.expired);

      final config = await licenseService.getConfig();
      expect(config!.mode, 'LOCKED');
    },
  );

  test('runFarmIdCascade cascades farm_id update across tables', () async {
    const localFarmId = 'local_farm_id';
    await db
        .into(db.farms)
        .insert(
          FarmsCompanion.insert(
            id: localFarmId,
            name: 'My Local Farm',
            capacity: 500,
            userId: 'local_user',
          ),
        );

    const batchId = 'batch_id';
    await db
        .into(db.batches)
        .insert(
          BatchesCompanion.insert(
            id: batchId,
            farmId: localFarmId,
            arrivalDate: DateTime.now(),
            currentCount: 100,
            initialCount: 100,
          ),
        );

    const houseId = 'house_id';
    await db
        .into(db.houses)
        .insert(
          HousesCompanion.insert(
            id: houseId,
            farmId: localFarmId,
            name: 'House A',
            capacity: 100,
          ),
        );

    await db
        .into(db.licenseConfigs)
        .insert(
          LicenseConfigsCompanion.insert(
            id: 'singleton',
            mode: const Value('PURE_OFFLINE'),
            farmId: const Value(localFarmId),
            installedAt: Value(DateTime.now()),
            expiresAt: DateTime.now().add(const Duration(days: 30)),
            lastUsed: Value(DateTime.now()),
          ),
        );

    const webFarmId = 'web_farm_id';
    await licenseService.runFarmIdCascade(
      localFarmId: localFarmId,
      webFarmId: webFarmId,
    );

    final farm = await (db.select(
      db.farms,
    )..where((t) => t.id.equals(webFarmId))).getSingleOrNull();
    expect(farm, isNotNull);
    final oldFarm = await (db.select(
      db.farms,
    )..where((t) => t.id.equals(localFarmId))).getSingleOrNull();
    expect(oldFarm, isNull);

    final batch = await (db.select(
      db.batches,
    )..where((t) => t.id.equals(batchId))).getSingle();
    expect(batch.farmId, webFarmId);

    final house = await (db.select(
      db.houses,
    )..where((t) => t.id.equals(houseId))).getSingle();
    expect(house.farmId, webFarmId);

    final config = await licenseService.getConfig();
    expect(config!.farmId, webFarmId);
  });

  test('mergeLocalFarmIntoCloud merges genesis when cloud farm already exists', () async {
    const localFarmId = FarmUtils.localGenesisFarmId;
    const webFarmId = 'web_farm_id';
    const houseId = 'house_id';

    await db.into(db.farms).insert(
          FarmsCompanion.insert(
            id: localFarmId,
            name: 'Local Offline Farm',
            capacity: 0,
            userId: 'local_user',
          ),
        );
    await db.into(db.farms).insert(
          FarmsCompanion.insert(
            id: webFarmId,
            name: 'Cloud Farm',
            capacity: 1000,
            userId: 'cloud_user',
          ),
        );
    await db.into(db.houses).insert(
          HousesCompanion.insert(
            id: houseId,
            farmId: localFarmId,
            name: 'House A',
            capacity: 100,
          ),
        );

    await licenseService.mergeLocalFarmIntoCloud(
      localFarmId: localFarmId,
      webFarmId: webFarmId,
    );

    final genesisFarm = await (db.select(db.farms)
          ..where((t) => t.id.equals(localFarmId)))
        .getSingleOrNull();
    expect(genesisFarm, isNull);

    final house = await (db.select(db.houses)
          ..where((t) => t.id.equals(houseId)))
        .getSingle();
    expect(house.farmId, webFarmId);
  });

  test(
    'linkCloudAccount authenticates, cascades farm_id, preserves expiry, and sets CLOUD_TRIAL',
    () async {
      final testService = TestLicenseService(db);

      // Seed initial PURE_OFFLINE license
      final initialExpiry = DateTime.now().add(const Duration(days: 25));
      await db
          .into(db.licenseConfigs)
          .insert(
            LicenseConfigsCompanion.insert(
              id: 'singleton',
              mode: const Value('PURE_OFFLINE'),
              farmId: const Value('local_farm_id'),
              installedAt: Value(DateTime.now()),
              expiresAt: initialExpiry,
              lastUsed: Value(DateTime.now()),
            ),
          );

      // Seed local tables
      await db
          .into(db.farms)
          .insert(
            FarmsCompanion.insert(
              id: 'local_farm_id',
              name: 'My Local Farm',
              capacity: 500,
              userId: 'local_user',
            ),
          );

      // Trigger migration
      testService.mockUserId = 'web_user_id';
      testService.mockWebFarmId = 'web_farm_id';

      final err = await testService.linkCloudAccount(
        email: 'test@example.com',
        password: 'password',
        hardwareId: 'device123',
      );
      expect(err, isNull);

      // Verify config is updated to CLOUD_TRIAL, keeping preserved expiry
      final config = await testService.getConfig();
      expect(config, isNotNull);
      expect(config!.mode, 'CLOUD_TRIAL');
      expect(config.farmId, 'web_farm_id');
      expect(config.userId, 'web_user_id');
      expect(config.hardwareId, 'device123');
      expect(
        config.expiresAt.difference(initialExpiry).inSeconds.abs() <= 1,
        isTrue,
      );

      // Verify cascade of other tables
      final farm = await (db.select(
        db.farms,
      )..where((t) => t.id.equals('web_farm_id'))).getSingleOrNull();
      expect(farm, isNotNull);
      final oldFarm = await (db.select(
        db.farms,
      )..where((t) => t.id.equals('local_farm_id'))).getSingleOrNull();
      expect(oldFarm, isNull);
    },
  );
}

class TestLicenseService extends LicenseService {
  TestLicenseService(super.db);

  String? mockUserId;
  String? mockWebFarmId;
  bool shouldThrow = false;

  @override
  Future<Map<String, dynamic>?> fetchSupabaseFarmAndUser({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) {
      throw Exception('Mock auth error');
    }
    return {
      'userId': mockUserId ?? 'mock_user_id',
      'webFarmId': mockWebFarmId ?? 'mock_web_farm_id',
    };
  }

  @override
  Future<void> registerDeviceOnSupabase({
    required String userId,
    required String? webFarmId,
    required String hardwareId,
  }) async {
    // No-op for testing
  }
}
