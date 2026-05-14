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
    final userId = prefs.getString('user_id');
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

      await _pushChanges(userId);
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

  Future<void> _pushChanges(String? legacyUserId) async {
    final String currentUserId = _supabase.auth.currentUser?.id ?? '';
    debugPrint('--- SYNC DIAGNOSTICS ---');
    debugPrint('legacyUserId: $legacyUserId');
    debugPrint('currentUserId: $currentUserId');
    try {
      final rpcResult = await _supabase.rpc('get_legacy_user_id');
      debugPrint('RPC get_legacy_user_id result: $rpcResult');
    } catch (e) {
      debugPrint('RPC get_legacy_user_id error: $e');
    }
    debugPrint('------------------------');

    // 0.1 Push Houses
    final pendingHouses = await (db.select(db.houses)..where((t) => t.synced.equals(false))).get();
    for (var h in pendingHouses) {
      try {
        final now = DateTime.now().toUtc().toIso8601String();
        final payload = {
          'farmId': h.farmId,
          'userId': h.userId ?? legacyUserId,
          'name': h.name,
          'capacity': h.capacity,
          'currentTemperature': h.currentTemperature,
          'currentHumidity': h.currentHumidity,
          'isIsolation': h.isIsolation,
          'createdAt': now,
          'updatedAt': now,
        };
        debugPrint('Pushing house: $payload');
        final response = await _supabase.from('houses').insert(payload).select().single();
        
        final newId = response['id'] as int;
        if (newId != h.id) {
          await (db.update(db.batches)..where((t) => t.houseId.equals(h.id))).write(BatchesCompanion(houseId: Value(newId)));
        }
        await (db.update(db.houses)..where((t) => t.id.equals(h.id))).write(HousesCompanion(id: Value(newId), synced: const Value(true)));
      } catch (e) {
        debugPrint("House push error: $e");
      }
    }

    // 0.2 Push Batches
    final pendingBatches = await (db.select(db.batches)..where((t) => t.synced.equals(false))).get();
    for (var b in pendingBatches) {
      try {
        final batchNow = DateTime.now().toUtc().toIso8601String();
        final response = await _supabase.from('batches').insert({
          'farmId': b.farmId,
          'houseId': b.houseId,
          'userId': b.userId ?? legacyUserId,
          'batchName': b.batchName,
          'type': b.type,
          'status': b.status,
          'breedType': b.breedType,
          'arrivalDate': b.arrivalDate.toIso8601String(),
          'currentCount': b.currentCount,
          'initialCount': b.initialCount,
          'isolationCount': b.isolationCount,
          'initial_actual_cost': b.initialActualCost,
          'growth_target': b.growthTarget,
          'createdAt': batchNow,
          'updatedAt': batchNow,
        }).select().single();
        
        final newId = response['id'] as int;
        if (newId != b.id) {
          await (db.update(db.mortalities)..where((t) => t.batchId.equals(b.id))).write(MortalitiesCompanion(batchId: Value(newId)));
          await (db.update(db.eggProductions)..where((t) => t.batchId.equals(b.id))).write(EggProductionsCompanion(batchId: Value(newId)));
          await (db.update(db.feedingLogs)..where((t) => t.batchId.equals(b.id))).write(FeedingLogsCompanion(batchId: Value(newId)));
        }
        await (db.update(db.batches)..where((t) => t.id.equals(b.id))).write(BatchesCompanion(id: Value(newId), synced: const Value(true)));
      } catch (e) {
        debugPrint("Batch push error: $e");
      }
    }

    // 1. Push Mortalities
    final pendingMortalities = await (db.select(db.mortalities)..where((t) => t.synced.equals(false))).get();
    for (var m in pendingMortalities) {
      try {
        final response = await _supabase.from('mortality').insert({
          'farmId': m.farmId,
          'batchId': m.batchId,
          'count': m.count,
          'reason': m.reason,
          'category': m.category,
          'sub_category': m.subCategory,
          'logDate': m.logDate.toIso8601String(),
          'userId': m.userId ?? legacyUserId,
        }).select().single();
        
        final newId = response['id'] as int;
        await (db.update(db.mortalities)..where((t) => t.id.equals(m.id))).write(MortalitiesCompanion(id: Value(newId), synced: const Value(true)));
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
          'user_id': f.userId ?? legacyUserId,
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
          'userId': e.userId ?? legacyUserId,
        });
        await (db.update(db.eggProductions)..where((t) => t.id.equals(e.id))).write(const EggProductionsCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint("Egg push error: $e");
      }
    }
    // 4. Push Customers
    final pendingCustomers = await (db.select(db.customers)..where((t) => t.synced.equals(false))).get();
    for (var c in pendingCustomers) {
      try {
        final response = await _supabase.from('customers').upsert({
          'id': c.id,
          'farmId': c.farmId,
          'name': c.name,
          'phone': c.phone,
          'email': c.email,
          'address': c.address,
          'customerType': c.customerType,
          'balanceOwed': c.balanceOwed,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        }).select().single();
        
        final newId = response['id'] as int;
        await (db.update(db.customers)..where((t) => t.id.equals(c.id))).write(CustomersCompanion(id: Value(newId), synced: const Value(true)));
      } catch (e) {
        debugPrint("Customer push error: $e");
      }
    }

    // 5. Push Sales
    final pendingSales = await (db.select(db.sales)..where((t) => t.synced.equals(false))).get();
    for (var s in pendingSales) {
      try {
        final response = await _supabase.from('sales').insert({
          'farmId': s.farmId,
          'batchId': s.batchId,
          'customerId': s.customerId,
          'quantity': s.quantity,
          'unitPrice': s.unitPrice,
          'totalAmount': s.totalAmount,
          'saleDate': s.saleDate.toIso8601String(),
          'userId': s.userId ?? legacyUserId,
        }).select().single();
        
        final newId = response['id'] as int;
        await (db.update(db.sales)..where((t) => t.id.equals(s.id))).write(SalesCompanion(id: Value(newId), synced: const Value(true)));
      } catch (e) {
        debugPrint("Sale push error: $e");
      }
    }

    // 7. Push Inventory
    final pendingInv = await (db.select(db.inventory)..where((t) => t.synced.equals(false))).get();
    for (var i in pendingInv) {
      try {
        final response = await _supabase.from('inventory').upsert({
          'id': i.id,
          'farmId': i.farmId,
          'userId': i.userId ?? legacyUserId,
          'itemName': i.itemName,
          'stockLevel': i.stockLevel,
          'reorderLevel': i.reorderLevel,
          'unit': i.unit,
          'category': i.category,
          'costPerUnit': i.costPerUnit,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        }).select().single();
        
        final newId = response['id'] as int;
        await (db.update(db.inventory)..where((t) => t.id.equals(i.id))).write(InventoryCompanion(id: Value(newId), synced: const Value(true)));
      } catch (e) {
        debugPrint("Inventory push error: $e");
      }
    }

    // 8. Push Weight Records
    final pendingWeights = await (db.select(db.weightRecords)..where((t) => t.synced.equals(false))).get();
    for (var w in pendingWeights) {
      try {
        final response = await _supabase.from('weight_records').insert({
          'farmId': w.farmId,
          'batchId': w.batchId,
          'averageWeight': w.averageWeight,
          'logDate': w.logDate.toIso8601String(),
          'userId': w.userId ?? legacyUserId,
        }).select().single();
        
        final newId = response['id'] as int;
        await (db.update(db.weightRecords)..where((t) => t.id.equals(w.id))).write(WeightRecordsCompanion(id: Value(newId), synced: const Value(true)));
      } catch (e) {
        debugPrint("Weight push error: $e");
      }
    }

    // 9. Push Farm Settings
    final pendingSettings = await (db.select(db.farmSettings)..where((t) => t.synced.equals(false))).get();
    for (var s in pendingSettings) {
      try {
        await _supabase.from('farm_settings').upsert({
          'farmId': s.farmId,
          'currency': s.currency,
          'eggRecordReminderTime': s.eggRecordReminderTime,
          'feedRecordReminderTime': s.feedRecordReminderTime,
          'growthTargetStandard': s.growthTargetStandard,
          'eggsPerCrate': s.eggsPerCrate,
        });
        await (db.update(db.farmSettings)..where((t) => t.farmId.equals(s.farmId))).write(const FarmSettingsCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint("Settings push error: $e");
      }
    }

    // 10. Push Users
    final pendingUsers = await (db.select(db.users)..where((t) => t.synced.equals(false))).get();
    for (var u in pendingUsers) {
      try {
        await _supabase.from('users').upsert({
          'id': u.id,
          'firstname': u.firstname,
          'surname': u.surname,
          'middleName': u.middleName,
          'name': u.name,
          'email': u.email,
          'phoneNumber': u.phoneNumber,
          'role': u.role,
          'mustChangePassword': u.mustChangePassword,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        });
        await (db.update(db.users)..where((t) => t.id.equals(u.id))).write(const UsersCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint("User push error: $e");
      }
    }

    // 11. Push Farm Members
    final pendingMembers = await (db.select(db.farmMembers)..where((t) => t.synced.equals(false))).get();
    for (var m in pendingMembers) {
      try {
        await _supabase.from('farm_members').upsert({
          'farmId': m.farmId,
          'userId': m.userId,
          'role': m.role,
          'joinedAt': m.joinedAt.toIso8601String(),
        });
        await (db.update(db.farmMembers)..where((t) => t.id.equals(m.id))).write(const FarmMembersCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint("Member push error: $e");
      }
    }
  }

  Future<void> _pullChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final farmId = prefs.getInt('bound_farm_id');
    if (farmId == null) return;

    try {
      final syncData = await _supabase.rpc('get_farm_sync_data', params: {'p_farm_id': farmId});
      if (syncData == null) return;

      // 1. Pull Houses
      final remoteHouses = (syncData['houses'] as List<dynamic>?) ?? [];
      for (var h in remoteHouses) {
        await db.into(db.houses).insertOnConflictUpdate(HousesCompanion.insert(
          id: Value(h['id'] as int),
          farmId: farmId,
          userId: Value(h['userId'] as String?),
          name: h['name'] as String,
          capacity: h['capacity'] as int,
          currentTemperature: Value(h['currentTemperature'] != null ? double.parse(h['currentTemperature'].toString()) : null),
          currentHumidity: Value(h['currentHumidity'] != null ? double.parse(h['currentHumidity'].toString()) : null),
          isIsolation: Value(h['isIsolation'] as bool? ?? false),
          synced: const Value(true),
        ));
      }
      debugPrint('Pull: synced ${remoteHouses.length} houses');

      // 2. Pull Batches
      final remoteBatches = (syncData['batches'] as List<dynamic>?) ?? [];
      for (var rb in remoteBatches) {
        await db.into(db.batches).insertOnConflictUpdate(BatchesCompanion.insert(
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
        ));
      }
      debugPrint('Pull: synced ${remoteBatches.length} batches');

      // 3. Pull Inventory
      final remoteInventory = (syncData['inventory'] as List<dynamic>?) ?? [];
      for (var i in remoteInventory) {
        await db.into(db.inventory).insertOnConflictUpdate(InventoryCompanion.insert(
          id: Value(i['id'] as int),
          farmId: farmId,
          userId: Value(i['userId'] as String?),
          itemName: i['itemName'] as String,
          stockLevel: double.parse(i['stockLevel'].toString()),
          reorderLevel: Value(i['reorderLevel'] != null ? double.parse(i['reorderLevel'].toString()) : null),
          unit: i['unit'] as String,
          category: Value(i['category'] as String?),
          costPerUnit: Value(i['costPerUnit'] != null ? double.parse(i['costPerUnit'].toString()) : null),
          synced: const Value(true),
        ));
      }
      debugPrint('Pull: synced ${remoteInventory.length} inventory items');

      // 4. Pull Customers
      final remoteCustomers = (syncData['customers'] as List<dynamic>?) ?? [];
      for (var c in remoteCustomers) {
        await db.into(db.customers).insertOnConflictUpdate(CustomersCompanion.insert(
          id: Value(c['id'] as int),
          farmId: farmId,
          name: c['name'] as String,
          phone: Value(c['phone'] as String?),
          email: Value(c['email'] as String?),
          address: Value(c['address'] as String?),
          customerType: Value(c['customerType'] as String? ?? 'CUSTOMER'),
          balanceOwed: Value(c['balanceOwed'] != null ? double.parse(c['balanceOwed'].toString()) : 0.0),
          synced: const Value(true),
        ));
      }
      debugPrint('Pull: synced ${remoteCustomers.length} customers');

      // 5. Pull Mortality (direct table query)
      final remoteMortality = await _supabase
          .from('mortality')
          .select()
          .eq('farmId', farmId);
      for (var m in remoteMortality) {
        await db.into(db.mortalities).insertOnConflictUpdate(MortalitiesCompanion.insert(
          id: Value(m['id'] as int),
          farmId: farmId,
          batchId: m['batchId'] as int,
          count: m['count'] as int,
          reason: Value(m['reason'] as String?),
          category: Value(m['category'] as String?),
          subCategory: Value(m['sub_category'] as String?),
          logDate: DateTime.parse(m['logDate'] as String),
          userId: Value(m['userId'] as String?),
          synced: const Value(true),
        ));
      }
      debugPrint('Pull: synced ${remoteMortality.length} mortality records');

      // 6. Pull Egg Production (direct table query)
      final remoteEggs = await _supabase
          .from('egg_production')
          .select()
          .eq('farmId', farmId);
      for (var e in remoteEggs) {
        await db.into(db.eggProductions).insertOnConflictUpdate(EggProductionsCompanion.insert(
          id: Value(e['id'] as int),
          farmId: farmId,
          batchId: e['batchId'] as int,
          categoryId: Value(e['categoryId'] as int?),
          eggsCollected: e['eggsCollected'] as int,
          unusableCount: Value(e['unusableCount'] as int? ?? 0),
          eggsRemaining: Value(e['eggsRemaining'] as int? ?? 0),
          cratesCollected: Value(e['cratesCollected'] != null ? double.parse(e['cratesCollected'].toString()) : null),
          qualityGrade: Value(e['qualityGrade'] as String?),
          logDate: DateTime.parse(e['logDate'] as String),
          userId: Value(e['userId'] as String?),
          synced: const Value(true),
        ));
      }
      debugPrint('Pull: synced ${remoteEggs.length} egg production records');

      // 7. Pull Feeding Logs (direct table query)
      final remoteFeeds = await _supabase
          .from('daily_feeding_logs')
          .select()
          .eq('farmId', farmId);
      for (var f in remoteFeeds) {
        await db.into(db.feedingLogs).insertOnConflictUpdate(FeedingLogsCompanion.insert(
          id: Value(f['id'] as int),
          farmId: farmId,
          batchId: Value(f['batch_id'] as int?),
          feedTypeId: Value(f['feed_type_id'] as int?),
          formulationId: Value(f['formulation_id'] as int?),
          amountConsumed: double.parse(f['amount_consumed'].toString()),
          logDate: DateTime.parse(f['log_date'] as String),
          userId: Value(f['user_id'] as String?),
          synced: const Value(true),
        ));
      }
      debugPrint('Pull: synced ${remoteFeeds.length} feeding logs');

      // 10. Pull Users and Farm Members
      final teamData = await _supabase.from('users').select('*, farm_members(*)').eq('farm_members.farmId', farmId);
      for (var u in teamData) {
        final userId = u['id'] as String;
        await db.into(db.users).insertOnConflictUpdate(UsersCompanion.insert(
          id: userId,
          firstname: u['firstname'] ?? '',
          surname: u['surname'] ?? '',
          name: u['name'] ?? '',
          email: u['email'] ?? '',
          phoneNumber: u['phoneNumber'] ?? '',
          role: u['role'] ?? 'worker',
          mustChangePassword: Value(u['mustChangePassword'] ?? false),
          synced: const Value(true),
        ));

        final members = u['farm_members'] as List;
        for (var m in members) {
          await db.into(db.farmMembers).insertOnConflictUpdate(FarmMembersCompanion.insert(
            farmId: farmId,
            userId: userId,
            role: m['role'] ?? 'worker',
            joinedAt: Value(DateTime.parse(m['joinedAt'])),
            synced: const Value(true),
          ));
        }
      }
      debugPrint("Pull: synced ${teamData.length} team members");

      notifyListeners();
    } catch (e) {
      debugPrint('Pull changes error: $e');
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
    super.dispose();
  }
}
