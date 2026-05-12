import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import 'local_db.dart';

class SyncEngine extends ChangeNotifier {
  final AppDatabase db;
  final _supabase = Supabase.instance.client;
  final Connectivity _connectivity = Connectivity();
  
  bool _isOnline = false;
  bool get isOnline => _isOnline;
  
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  
  final _syncStatusController = StreamController<bool>.broadcast();
  Stream<bool> get syncStatus => _syncStatusController.stream;

  Timer? _syncTimer;

  SyncEngine(this.db) {
    _initConnectivity();
  }

  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_isOnline) syncNow();
    });
  }

  Future<void> syncNow() => performSync();

  Future<void> _initConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateOnlineStatus(results);
    
    _connectivity.onConnectivityChanged.listen((results) {
      _updateOnlineStatus(results);
    });
  }

  void _updateOnlineStatus(List<ConnectivityResult> results) {
    bool online = !results.contains(ConnectivityResult.none);
    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
      if (_isOnline) {
        performSync();
      }
    }
  }

  Future<void> performSync() async {
    if (_isSyncing || !_isOnline) return;

    final prefs = await SharedPreferences.getInstance();
    final farmId = prefs.getInt('bound_farm_id');
    if (farmId == null) return;
    
    _isSyncing = true;
    _syncStatusController.add(true);
    notifyListeners();

    try {
      final bool isOwner = await _supabase.rpc('verify_farm_binding', params: {
        'p_farm_id': farmId,
      });

      if (!isOwner) {
        throw Exception("Unauthorized: You do not have permission to manage this Farm ID (#$farmId). Sync aborted.");
      }

      await _pushChanges();
      await _pullChanges();
      
    } catch (e) {
      debugPrint("Sync error: $e");
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
      notifyListeners();
    }
  }

  Future<void> initialFullSync(int farmId) async {
    if (!_isOnline) throw Exception("No internet connection for initial sync");

    _isSyncing = true;
    _syncStatusController.add(true);
    notifyListeners();

    try {
      final data = await _supabase.rpc('get_farm_sync_data', params: {
        'p_farm_id': farmId,
      });

      if (data == null) {
        throw Exception("Farm not found or Permission Denied. Binding refused.");
      }

      // 0. Hardware Binding
      try {
        final deviceInfo = DeviceInfoPlugin();
        String deviceId = "unknown_device";
        String deviceName = "Unknown Desktop";

        if (Platform.isWindows) {
          final windowsInfo = await deviceInfo.windowsInfo;
          deviceId = windowsInfo.deviceId; 
          deviceName = windowsInfo.computerName;
        }

        await _supabase.rpc('register_hardware_device', params: {
          'p_farm_id': farmId,
          'p_device_id': deviceId,
          'p_device_name': deviceName,
        });
      } catch (e) {
        debugPrint("Hardware registration warning: $e");
      }

      // 1. Farm
      final remoteFarm = data['farm'] as Map<String, dynamic>;
      await db.into(db.farms).insertOnConflictUpdate(FarmsCompanion.insert(
        id: Value(remoteFarm['id'] as int),
        name: remoteFarm['name'] as String,
        capacity: remoteFarm['capacity'] as int,
        userId: remoteFarm['userId'] as String? ?? '',
        location: Value(remoteFarm['location'] as String?),
        subscriptionTier: Value(remoteFarm['subscriptionTier'] as String? ?? 'FREE'),
      ));

      // 2. Farm Settings
      final remoteSettings = data['farm_settings'] as Map<String, dynamic>?;
      if (remoteSettings != null) {
        await db.into(db.farmSettings).insertOnConflictUpdate(FarmSettingsCompanion.insert(
          id: Value(remoteSettings['id'] as int),
          farmId: remoteSettings['farmId'] as int,
          currency: Value(remoteSettings['currency'] as String? ?? 'GHS'),
          eggRecordReminderTime: Value(remoteSettings['eggRecordReminderTime'] as String?),
          feedRecordReminderTime: Value(remoteSettings['feedRecordReminderTime'] as String?),
          growthTargetStandard: Value(remoteSettings['growth_target_standard'] as int?),
          eggsPerCrate: Value(remoteSettings['eggsPerCrate'] as int? ?? 30),
        ));
      }

      // 3. Users
      final remoteUsers = (data['users'] as List<dynamic>?) ?? [];
      for (var u in remoteUsers) {
        final user = u as Map<String, dynamic>;
        await db.into(db.users).insertOnConflictUpdate(UsersCompanion.insert(
          id: user['id'] as String,
          firstname: Value(user['firstname'] as String?),
          surname: Value(user['surname'] as String?),
          middleName: Value(user['middle_name'] as String?),
          name: Value(user['name'] as String?),
          email: Value(user['email'] as String?),
          image: Value(user['image'] as String?),
          password: Value(user['password'] as String?),
          phoneNumber: Value(user['phone_number'] as String?),
          mustChangePassword: Value(user['must_change_password'] as bool? ?? false),
          role: Value(user['role'] as String? ?? 'WORKER'),
        ));
      }

      // 4. Houses
      final remoteHouses = (data['houses'] as List<dynamic>?) ?? [];
      for (var h in remoteHouses) {
        final house = h as Map<String, dynamic>;
        await db.into(db.houses).insertOnConflictUpdate(HousesCompanion.insert(
          id: Value(house['id'] as int),
          farmId: farmId,
          userId: Value(house['userId'] as String?),
          name: house['name'] as String,
          capacity: house['capacity'] as int,
          currentTemperature: Value(house['currentTemperature'] != null ? double.parse(house['currentTemperature'].toString()) : null),
          currentHumidity: Value(house['currentHumidity'] != null ? double.parse(house['currentHumidity'].toString()) : null),
          isIsolation: Value(house['isIsolation'] as bool? ?? false),
          synced: const Value(true),
        ));
      }

      // 5. Inventory
      final remoteInventory = (data['inventory'] as List<dynamic>?) ?? [];
      for (var i in remoteInventory) {
        final item = i as Map<String, dynamic>;
        await db.into(db.inventory).insertOnConflictUpdate(InventoryCompanion.insert(
          id: Value(item['id'] as int),
          farmId: farmId,
          userId: Value(item['userId'] as String?),
          itemName: item['itemName'] as String,
          stockLevel: double.parse(item['stockLevel'].toString()),
          reorderLevel: Value(item['reorderLevel'] != null ? double.parse(item['reorderLevel'].toString()) : null),
          unit: item['unit'] as String,
          category: Value(item['category'] as String?),
          costPerUnit: Value(item['costPerUnit'] != null ? double.parse(item['costPerUnit'].toString()) : null),
          supplierId: Value(item['supplierId'] as int?),
          synced: const Value(true),
        ));
      }

      // 6. Batches
      final remoteBatches = (data['batches'] as List<dynamic>?) ?? [];
      for (var b in remoteBatches) {
        final batch = b as Map<String, dynamic>;
        await db.into(db.batches).insertOnConflictUpdate(BatchesCompanion.insert(
          id: Value(batch['id'] as int),
          farmId: farmId,
          houseId: Value(batch['houseId'] as int?),
          userId: Value(batch['userId'] as String?),
          batchName: Value(batch['batchName'] as String? ?? ''),
          type: Value(batch['type'] as String? ?? ''),
          breedType: Value(batch['breedType'] as String?),
          status: Value(batch['status'] as String? ?? ''),
          arrivalDate: DateTime.parse(batch['arrivalDate'] as String),
          currentCount: batch['currentCount'] as int,
          initialCount: batch['initialCount'] as int,
          isolationCount: Value(batch['isolationCount'] as int? ?? 0),
          initialActualCost: Value(batch['initial_actual_cost'] != null ? double.parse(batch['initial_actual_cost'].toString()) : null),
          growthTarget: Value(batch['growth_target'] as String?),
          synced: const Value(true),
        ));
      }

      // 7. Customers
      final remoteCustomers = (data['customers'] as List<dynamic>?) ?? [];
      for (var c in remoteCustomers) {
        final customer = c as Map<String, dynamic>;
        await db.into(db.customers).insertOnConflictUpdate(CustomersCompanion.insert(
          id: Value(customer['id'] as int),
          farmId: farmId,
          name: customer['name'] as String,
          phone: Value(customer['phone'] as String?),
          email: Value(customer['email'] as String?),
          address: Value(customer['address'] as String?),
          balanceOwed: Value(customer['balanceOwed'] != null ? double.parse(customer['balanceOwed'].toString()) : 0.0),
          synced: const Value(true),
        ));
      }

    } catch (e) {
      debugPrint("Initial Sync Error: $e");
      rethrow;
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
      notifyListeners();
    }
  }

  Future<void> _pushChanges() async {
    // 1. Push Mortalities
    final pendingMortalities = await (db.select(db.mortalities)..where((t) => t.synced.equals(false))).get();
    for (var m in pendingMortalities) {
      try {
        await _supabase.from('mortality').upsert({
          'id': m.id,
          'farmId': m.farmId,
          'batchId': m.batchId,
          'count': m.count,
          'reason': m.reason,
          'category': m.category,
          'sub_category': m.subCategory,
          'logDate': m.logDate.toIso8601String(),
          'userId': m.userId,
        });
        await (db.update(db.mortalities)..where((t) => t.id.equals(m.id))).write(const MortalitiesCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint("Mortality push error: $e");
      }
    }

    // 2. Push Feeding Logs
    final pendingFeeds = await (db.select(db.feedingLogs)..where((t) => t.synced.equals(false))).get();
    for (var f in pendingFeeds) {
      try {
        await _supabase.from('daily_feeding_logs').upsert({
          'id': f.id,
          'farmId': f.farmId,
          'batch_id': f.batchId,
          'feed_type_id': f.feedTypeId,
          'formulation_id': f.formulationId,
          'amount_consumed': f.amountConsumed,
          'log_date': f.logDate.toIso8601String(),
          'user_id': f.userId,
        });
        await (db.update(db.feedingLogs)..where((t) => t.id.equals(f.id))).write(const FeedingLogsCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint("Feeding push error: $e");
      }
    }

    // 3. Push Egg Production
    final pendingEggs = await (db.select(db.eggProductions)..where((t) => t.synced.equals(false))).get();
    for (var e in pendingEggs) {
      try {
        await _supabase.from('egg_production').upsert({
          'id': e.id,
          'farmId': e.farmId,
          'batchId': e.batchId,
          'categoryId': e.categoryId,
          'eggsCollected': e.eggsCollected,
          'unusableCount': e.unusableCount,
          'eggsRemaining': e.eggsRemaining,
          'cratesCollected': e.cratesCollected,
          'qualityGrade': e.qualityGrade,
          'logDate': e.logDate.toIso8601String(),
          'userId': e.userId,
        });
        await (db.update(db.eggProductions)..where((t) => t.id.equals(e.id))).write(const EggProductionsCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint("Egg push error: $e");
      }
    }
  }

  Future<void> _pullChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final farmId = prefs.getInt('bound_farm_id');
    if (farmId == null) return;

    try {
      final syncData = await _supabase.rpc('get_farm_sync_data', params: {'p_farm_id': farmId});
      
      if (syncData != null) {
        // 1. Update Users
        final remoteUsers = (syncData['users'] as List<dynamic>?) ?? [];
        await db.batch((b) {
          for (var u in remoteUsers) {
            b.insert(
              db.users,
              UsersCompanion.insert(
                id: u['id'] as String,
                firstname: Value(u['firstname'] as String?),
                surname: Value(u['surname'] as String?),
                name: Value(u['name'] as String?),
                email: Value(u['email'] as String?),
                role: Value(u['role'] as String? ?? 'WORKER'),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });

        // 2. Update Batches
        final remoteBatches = (syncData['batches'] as List<dynamic>?) ?? [];
        await db.batch((b) {
          for (var rb in remoteBatches) {
            b.insert(
              db.batches,
              BatchesCompanion.insert(
                id: Value(rb['id'] as int),
                farmId: farmId,
                houseId: Value(rb['houseId'] as int?),
                userId: Value(rb['userId'] as String?),
                batchName: Value(rb['batchName'] as String? ?? ''),
                type: Value(rb['type'] as String? ?? ''),
                breedType: Value(rb['breedType'] as String?),
                status: Value(rb['status'] as String? ?? ''),
                arrivalDate: DateTime.parse(rb['arrivalDate'] as String),
                currentCount: rb['currentCount'] as int? ?? 0,
                initialCount: rb['initialCount'] as int? ?? 0,
                isolationCount: Value(rb['isolationCount'] as int? ?? 0),
                initialActualCost: Value(rb['initial_actual_cost'] != null ? double.parse(rb['initial_actual_cost'].toString()) : null),
                growthTarget: Value(rb['growth_target'] as String?),
                synced: const Value(true),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      }
    } catch (e) {
      debugPrint("Pull changes error: $e");
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
    super.dispose();
  }
}
