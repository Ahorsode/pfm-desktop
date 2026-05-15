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

  void _updateSyncStatus(bool syncing) {
    if (!_syncStatusController.isClosed) {
      _syncStatusController.add(syncing);
    }
  }

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
    _updateSyncStatus(true);
    notifyListeners();

    try {
      final bool isOwner = await _supabase.rpc('verify_farm_binding', params: {
        'p_farm_id': farmId,
      });

      if (!isOwner) {
        throw Exception("Unauthorized: You do not have permission to manage this Farm ID (#$farmId). Sync aborted.");
      }

      await _pushChanges(userId);
      await _pushDeletions();
      await _pullChanges();
      
    } finally {
      _isSyncing = false;
      _updateSyncStatus(false);
      notifyListeners();
    }
  }

  Future<void> initialFullSync(int farmId) async {
    if (!_isOnline) throw Exception("No internet connection for initial sync");

    _isSyncing = true;
    _updateSyncStatus(true);
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
          userId: Value(house['user_id'] as String? ?? house['userId'] as String?),
          name: house['name'] as String,
          capacity: house['capacity'] as int,
          currentTemperature: Value((house['current_temperature'] ?? house['currentTemperature']) != null ? double.parse((house['current_temperature'] ?? house['currentTemperature']).toString()) : null),
          currentHumidity: Value((house['current_humidity'] ?? house['currentHumidity']) != null ? double.parse((house['current_humidity'] ?? house['currentHumidity']).toString()) : null),
          isIsolation: Value((house['is_isolation'] ?? house['isIsolation'] ?? false) as bool),
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
          userId: Value(item['user_id'] as String? ?? item['userId'] as String?),
          itemName: (item['item_name'] ?? item['itemName']) as String,
          stockLevel: double.parse((item['stock_level'] ?? item['stockLevel']).toString()),
          reorderLevel: Value((item['reorder_level'] ?? item['reorderLevel']) != null ? double.parse((item['reorder_level'] ?? item['reorderLevel']).toString()) : null),
          unit: item['unit'] as String,
          category: Value(item['category'] as String?),
          costPerUnit: Value((item['cost_per_unit'] ?? item['costPerUnit']) != null ? double.parse((item['cost_per_unit'] ?? item['costPerUnit']).toString()) : null),
          supplierId: Value((item['supplier_id'] ?? item['supplierId']) as int?),
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
          houseId: Value(batch['house_id'] as int? ?? batch['houseId'] as int?),
          userId: Value(batch['user_id'] as String? ?? batch['userId'] as String?),
          batchName: Value(batch['batch_name'] as String? ?? batch['batchName'] as String? ?? ''),
          type: Value(batch['type'] as String? ?? ''),
          breedType: Value(batch['breed_type'] as String? ?? batch['breedType'] as String?),
          status: Value(batch['status'] as String? ?? ''),
          arrivalDate: DateTime.parse((batch['arrival_date'] ?? batch['arrivalDate']) as String),
          currentCount: (batch['current_count'] ?? batch['currentCount']) as int,
          initialCount: (batch['initial_count'] ?? batch['initialCount']) as int,
          isolationCount: Value((batch['isolation_count'] ?? batch['isolationCount'] ?? 0) as int),
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
          customerType: Value(customer['customerType'] as String? ?? 'CUSTOMER'),
          supplyItems: Value(customer['supplyItems'] as String?),
          contactPerson: Value(customer['contactPerson'] as String?),
          synced: const Value(true),
        ));
      }

      // 8. Expenses
      final remoteExpenses = await _supabase.from('expenses').select().eq('farmId', farmId);
      for (var e in remoteExpenses) {
        await db.into(db.expenses).insertOnConflictUpdate(ExpensesCompanion.insert(
          id: Value(e['id'] as int),
          farmId: farmId,
          category: e['category'] as String,
          amount: double.parse(e['amount'].toString()),
          date: Value(DateTime.parse(e['date'] as String)),
          description: Value(e['description'] as String?),
          synced: const Value(true),
        ));
      }

      // 9. Settlements
      final remoteSettlements = await _supabase.from('settlements').select().eq('farmId', farmId);
      for (var s in remoteSettlements) {
        await db.into(db.settlements).insertOnConflictUpdate(SettlementsCompanion.insert(
          id: Value(s['id'] as int),
          farmId: farmId,
          customerId: s['customerId'] as int,
          amount: double.parse(s['amount'].toString()),
          settlementDate: Value(DateTime.parse(s['settlementDate'] as String)),
          settlementType: s['settlementType'] as String,
          synced: const Value(true),
        ));
      }

      // 10. Stock Logs
      final remoteStockLogs = await _supabase.from('stock_logs').select().eq('farm_id', farmId);
      for (var sl in remoteStockLogs) {
        await db.into(db.stockLogs).insertOnConflictUpdate(StockLogsCompanion.insert(
          id: Value(sl['id'] as int),
          farmId: farmId,
          itemId: sl['item_id'] as int,
          quantity: double.parse(sl['quantity'].toString()),
          logType: sl['log_type'] as String,
          batchId: Value(sl['batch_id'] as int?),
          supplierId: Value(sl['supplier_id'] as int?),
          note: Value(sl['note'] as String?),
          logDate: Value(DateTime.parse(sl['log_date'] as String)),
          synced: const Value(true),
        ));
      }

    } catch (e) {
      debugPrint("Initial Sync Error: $e");
      rethrow;
    } finally {
      _isSyncing = false;
      _updateSyncStatus(false);
      notifyListeners();
    }
  }

  Future<void> _pushChanges(String? legacyUserId) async {
    debugPrint('--- SYNC PUSH START ---');

    try {
      // 1. Push Houses (camelCase columns)
      final pendingHouses = await (db.select(db.houses)..where((t) => t.synced.equals(false))).get();
      for (var h in pendingHouses) {
        try {
          final existing = await _supabase.from('houses').select('id').eq('id', h.id).maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'farmId': h.farmId,
            'userId': h.userId ?? legacyUserId,
            'name': h.name,
            'capacity': h.capacity,
            'currentTemperature': h.currentTemperature,
            'currentHumidity': h.currentHumidity,
            'isIsolation': h.isIsolation,
            'updatedAt': now,
          };

          if (existing != null) {
            await _supabase.from('houses').update(payload).eq('id', h.id);
            await (db.update(db.houses)..where((t) => t.id.equals(h.id))).write(const HousesCompanion(synced: Value(true)));
          } else {
            payload['createdAt'] = now;
            final response = await _supabase.from('houses').insert(payload).select().single();
            final newId = response['id'] as int;
            if (newId != h.id) {
              await (db.update(db.batches)..where((t) => t.houseId.equals(h.id))).write(BatchesCompanion(houseId: Value(newId)));
            }
            await (db.update(db.houses)..where((t) => t.id.equals(h.id))).write(HousesCompanion(id: Value(newId), synced: const Value(true)));
          }
        } catch (e) {
          debugPrint("House push error: $e");
        }
      }

      // 2. Push Batches (Mixed camel/snake columns)
      final pendingBatches = await (db.select(db.batches)..where((t) => t.synced.equals(false))).get();
      for (var b in pendingBatches) {
        try {
          final existing = await _supabase.from('batches').select('id').eq('id', b.id).maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'farmId': b.farmId,
            'houseId': b.houseId,
            'userId': b.userId ?? legacyUserId,
            'batchName': b.batchName,
            'type': b.type,
            'breedType': b.breedType,
            'status': b.status,
            'arrivalDate': b.arrivalDate.toIso8601String(),
            'currentCount': b.currentCount,
            'initialCount': b.initialCount,
            'isolationCount': b.isolationCount,
            'initial_actual_cost': b.initialActualCost, // snake in Prisma
            'growth_target': b.growthTarget, // snake in Prisma
            'updatedAt': now,
          };

          if (existing != null) {
            await _supabase.from('batches').update(payload).eq('id', b.id);
            await (db.update(db.batches)..where((t) => t.id.equals(b.id))).write(const BatchesCompanion(synced: Value(true)));
          } else {
            payload['createdAt'] = now;
            final response = await _supabase.from('batches').insert(payload).select().single();
            final newId = response['id'] as int;
            if (newId != b.id) {
              await (db.update(db.mortalities)..where((t) => t.batchId.equals(b.id))).write(MortalitiesCompanion(batchId: Value(newId)));
              await (db.update(db.eggProductions)..where((t) => t.batchId.equals(b.id))).write(EggProductionsCompanion(batchId: Value(newId)));
              await (db.update(db.feedingLogs)..where((t) => t.batchId.equals(b.id))).write(FeedingLogsCompanion(batchId: Value(newId)));
            }
            await (db.update(db.batches)..where((t) => t.id.equals(b.id))).write(BatchesCompanion(id: Value(newId), synced: const Value(true)));
          }
        } catch (e) {
          debugPrint("Batch push error: $e");
        }
      }

      // 3. Push Inventory (camelCase columns)
      final pendingInventory = await (db.select(db.inventory)..where((t) => t.synced.equals(false))).get();
      for (var i in pendingInventory) {
        try {
          final existing = await _supabase.from('inventory').select('id').eq('id', i.id).maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'farmId': i.farmId,
            'userId': i.userId ?? legacyUserId,
            'itemName': i.itemName,
            'stockLevel': i.stockLevel,
            'reorderLevel': i.reorderLevel,
            'unit': i.unit,
            'category': i.category,
            'costPerUnit': i.costPerUnit,
            'supplierId': i.supplierId,
            'updatedAt': now,
          };

          if (existing != null) {
            await _supabase.from('inventory').update(payload).eq('id', i.id);
            await (db.update(db.inventory)..where((t) => t.id.equals(i.id))).write(const InventoryCompanion(synced: Value(true)));
          } else {
            payload['createdAt'] = now;
            final response = await _supabase.from('inventory').insert(payload).select().single();
            final newId = response['id'] as int;
            await (db.update(db.inventory)..where((t) => t.id.equals(i.id))).write(InventoryCompanion(id: Value(newId), synced: const Value(true)));
          }
        } catch (e) {
          debugPrint("Inventory push error: $e");
        }
      }

      // 4. Push Mortality (Mixed camel/snake columns)
      final pendingMortality = await (db.select(db.mortalities)..where((t) => t.synced.equals(false))).get();
      for (var m in pendingMortality) {
        try {
          final existing = await _supabase.from('mortality').select('id').eq('id', m.id).maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'farmId': m.farmId,
            'batch_id': m.batchId,
            'count': m.count,
            'reason': m.reason,
            'logDate': m.logDate.toIso8601String(),
            'user_id': m.userId ?? legacyUserId,
            'category': m.category,
            'sub_category': m.subCategory,
            'updatedAt': now,
          };

          if (existing != null) {
            await _supabase.from('mortality').update(payload).eq('id', m.id);
            await (db.update(db.mortalities)..where((t) => t.id.equals(m.id))).write(const MortalitiesCompanion(synced: Value(true)));
          } else {
            payload['createdAt'] = now;
            final response = await _supabase.from('mortality').insert(payload).select().single();
            final newId = response['id'] as int;
            await (db.update(db.mortalities)..where((t) => t.id.equals(m.id))).write(MortalitiesCompanion(id: Value(newId), synced: const Value(true)));
          }
        } catch (e) {
          debugPrint("Mortality push error: $e");
        }
      }

      // 5. Push Feeding Logs (camelCase columns)
      final pendingFeeding = await (db.select(db.feedingLogs)..where((t) => t.synced.equals(false))).get();
      for (var fl in pendingFeeding) {
        try {
          final existing = await _supabase.from('daily_feeding_logs').select('id').eq('id', fl.id).maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'farmId': fl.farmId,
            'batch_id': fl.batchId,
            'feed_type_id': fl.feedTypeId,
            'formulation_id': fl.formulationId,
            'amount_consumed': fl.amountConsumed,
            'log_date': fl.logDate.toIso8601String(),
            'user_id': fl.userId ?? legacyUserId,
            'updatedAt': now,
          };

          if (existing != null) {
            await _supabase.from('daily_feeding_logs').update(payload).eq('id', fl.id);
            await (db.update(db.feedingLogs)..where((t) => t.id.equals(fl.id))).write(const FeedingLogsCompanion(synced: Value(true)));
          } else {
            payload['createdAt'] = now;
            final response = await _supabase.from('daily_feeding_logs').insert(payload).select().single();
            final newId = response['id'] as int;
            await (db.update(db.feedingLogs)..where((t) => t.id.equals(fl.id))).write(FeedingLogsCompanion(id: Value(newId), synced: const Value(true)));
          }
        } catch (e) {
          debugPrint("Feeding push error: $e");
        }
      }

      // 6. Push Egg Production (camelCase columns)
      final pendingEggs = await (db.select(db.eggProductions)..where((t) => t.synced.equals(false))).get();
      for (var ep in pendingEggs) {
        try {
          final existing = await _supabase.from('egg_production').select('id').eq('id', ep.id).maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'farmId': ep.farmId,
            'batchId': ep.batchId,
            'categoryId': ep.categoryId,
            'eggsCollected': ep.eggsCollected,
            'unusableCount': ep.unusableCount,
            'eggsRemaining': ep.eggsRemaining,
            'cratesCollected': ep.cratesCollected,
            'qualityGrade': ep.qualityGrade,
            'logDate': ep.logDate.toIso8601String(),
            'userId': ep.userId ?? legacyUserId,
          };

          if (existing != null) {
            await _supabase.from('egg_production').update(payload).eq('id', ep.id);
            await (db.update(db.eggProductions)..where((t) => t.id.equals(ep.id))).write(const EggProductionsCompanion(synced: Value(true)));
          } else {
            payload['createdAt'] = now;
            final response = await _supabase.from('egg_production').insert(payload).select().single();
            final newId = response['id'] as int;
            await (db.update(db.eggProductions)..where((t) => t.id.equals(ep.id))).write(EggProductionsCompanion(id: Value(newId), synced: const Value(true)));
          }
        } catch (e) {
          debugPrint("Egg push error: $e");
        }
      }

      // 7. Push Sales (camelCase columns)
      final pendingSales = await (db.select(db.sales)..where((t) => t.synced.equals(false))).get();
      for (var s in pendingSales) {
        try {
          final existing = await _supabase.from('sales').select('id').eq('id', s.id).maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'farmId': s.farmId,
            'customerId': s.customerId,
            'userId': s.userId ?? legacyUserId,
            'totalAmount': s.totalAmount,
            'saleDate': s.saleDate.toIso8601String(),
            'updatedAt': now,
          };

          if (existing != null) {
            await _supabase.from('sales').update(payload).eq('id', s.id);
            await (db.update(db.sales)..where((t) => t.id.equals(s.id))).write(const SalesCompanion(synced: Value(true)));
          } else {
            payload['createdAt'] = now;
            final response = await _supabase.from('sales').insert(payload).select().single();
            final newId = response['id'] as int;
            await (db.update(db.sales)..where((t) => t.id.equals(s.id))).write(SalesCompanion(id: Value(newId), synced: const Value(true)));
          }
        } catch (e) {
          debugPrint("Sale push error: $e");
        }
      }

      // 8. Push Customers (camelCase columns)
      final pendingCustomers = await (db.select(db.customers)..where((t) => t.synced.equals(false))).get();
      for (var c in pendingCustomers) {
        try {
          final existing = await _supabase.from('customers').select('id').eq('id', c.id).maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'farmId': c.farmId,
            'name': c.name,
            'phone': c.phone,
            'email': c.email,
            'address': c.address,
            'balanceOwed': c.balanceOwed,
            'customerType': c.customerType,
            'supplyItems': c.supplyItems,
            'contactPerson': c.contactPerson,
            'updatedAt': now,
          };

          if (existing != null) {
            await _supabase.from('customers').update(payload).eq('id', c.id);
            await (db.update(db.customers)..where((t) => t.id.equals(c.id))).write(const CustomersCompanion(synced: Value(true)));
          } else {
            payload['createdAt'] = now;
            final response = await _supabase.from('customers').insert(payload).select().single();
            final newId = response['id'] as int;
            await (db.update(db.customers)..where((t) => t.id.equals(c.id))).write(CustomersCompanion(id: Value(newId), synced: const Value(true)));
          }
        } catch (e) {
          debugPrint("Customer push error: $e");
        }
      }

      // 9. Push Feed Types
      final pendingFeedTypes = await (db.select(db.feedTypes)..where((t) => t.synced.equals(false))).get();
      for (var ft in pendingFeedTypes) {
        try {
          final payload = {
            'farmId': ft.farmId,
            'name': ft.name,
            'description': ft.description,
            'currentStock': ft.currentStock,
            'costPerKg': ft.costPerKg,
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          };
          final existing = await _supabase.from('feed_types').select('id').eq('id', ft.id).maybeSingle();
          if (existing != null) {
            await _supabase.from('feed_types').update(payload).eq('id', ft.id);
            await (db.update(db.feedTypes)..where((t) => t.id.equals(ft.id))).write(const FeedTypesCompanion(synced: Value(true)));
          } else {
            final resp = await _supabase.from('feed_types').insert(payload).select().single();
            await (db.update(db.feedTypes)..where((t) => t.id.equals(ft.id))).write(FeedTypesCompanion(id: Value(resp['id']), synced: const Value(true)));
          }
        } catch (e) { debugPrint("FeedType push error: $e"); }
      }

      // 10. Push Feed Formulations
      final pendingFormulations = await (db.select(db.feedFormulations)..where((t) => t.synced.equals(false))).get();
      for (var ff in pendingFormulations) {
        try {
          final payload = {
            'farmId': ff.farmId,
            'name': ff.name,
            'description': ff.description,
            'isActive': ff.isActive,
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          };
          final existing = await _supabase.from('feed_formulations').select('id').eq('id', ff.id).maybeSingle();
          if (existing != null) {
            await _supabase.from('feed_formulations').update(payload).eq('id', ff.id);
            await (db.update(db.feedFormulations)..where((t) => t.id.equals(ff.id))).write(const FeedFormulationsCompanion(synced: Value(true)));
          } else {
            final resp = await _supabase.from('feed_formulations').insert(payload).select().single();
            await (db.update(db.feedFormulations)..where((t) => t.id.equals(ff.id))).write(FeedFormulationsCompanion(id: Value(resp['id']), synced: const Value(true)));
          }
        } catch (e) { debugPrint("FeedFormulation push error: $e"); }
      }


      // 11. Push Expenses
      final pendingExpenses = await (db.select(db.expenses)..where((t) => t.synced.equals(false))).get();
      for (var e in pendingExpenses) {
        try {
          final existing = await _supabase.from('expenses').select('id').eq('id', e.id).maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'farmId': e.farmId,
            'category': e.category,
            'amount': e.amount,
            'date': e.date.toIso8601String(),
            'description': e.description,
            'updatedAt': now,
          };

          if (existing != null) {
            await _supabase.from('expenses').update(payload).eq('id', e.id);
            await (db.update(db.expenses)..where((t) => t.id.equals(e.id))).write(const ExpensesCompanion(synced: Value(true)));
          } else {
            payload['createdAt'] = now;
            final response = await _supabase.from('expenses').insert(payload).select().single();
            await (db.update(db.expenses)..where((t) => t.id.equals(e.id))).write(ExpensesCompanion(id: Value(response['id'] as int), synced: const Value(true)));
          }
        } catch (e) { debugPrint("Expense push error: $e"); }
      }

      // 12. Push Settlements
      final pendingSettlements = await (db.select(db.settlements)..where((t) => t.synced.equals(false))).get();
      for (var s in pendingSettlements) {
        try {
          final existing = await _supabase.from('settlements').select('id').eq('id', s.id).maybeSingle();
          final now = DateTime.now().toUtc().toIso8601String();
          final payload = {
            'farmId': s.farmId,
            'customerId': s.customerId,
            'amount': s.amount,
            'settlementDate': s.settlementDate.toIso8601String(),
            'settlementType': s.settlementType,
            'updatedAt': now,
          };

          if (existing != null) {
            await _supabase.from('settlements').update(payload).eq('id', s.id);
            await (db.update(db.settlements)..where((t) => t.id.equals(s.id))).write(const SettlementsCompanion(synced: Value(true)));
          } else {
            payload['createdAt'] = now;
            final response = await _supabase.from('settlements').insert(payload).select().single();
            await (db.update(db.settlements)..where((t) => t.id.equals(s.id))).write(SettlementsCompanion(id: Value(response['id'] as int), synced: const Value(true)));
          }
        } catch (e) { debugPrint("Settlement push error: $e"); }
      }

      // 13. Push Stock Logs
      final pendingStockLogs = await (db.select(db.stockLogs)..where((t) => t.synced.equals(false))).get();
      for (var sl in pendingStockLogs) {
        try {
          final existing = await _supabase.from('stock_logs').select('id').eq('id', sl.id).maybeSingle();
          final payload = {
            'farm_id': sl.farmId,
            'item_id': sl.itemId,
            'quantity': sl.quantity,
            'log_type': sl.logType,
            'batch_id': sl.batchId,
            'supplier_id': sl.supplierId,
            'note': sl.note,
            'log_date': sl.logDate.toIso8601String(),
          };

          if (existing != null) {
            await _supabase.from('stock_logs').update(payload).eq('id', sl.id);
            await (db.update(db.stockLogs)..where((t) => t.id.equals(sl.id))).write(const StockLogsCompanion(synced: Value(true)));
          } else {
            final response = await _supabase.from('stock_logs').insert(payload).select().single();
            final newId = response['id'] as int;
            await (db.update(db.stockLogs)..where((t) => t.id.equals(sl.id))).write(StockLogsCompanion(id: Value(newId), synced: const Value(true)));
          }
        } catch (e) {
          debugPrint("StockLog push error: $e");
        }
      }

    } catch (e) {
      debugPrint("Push Changes overall error: $e");
    }
    debugPrint('--- SYNC PUSH END ---');
  }

  Future<void> _pushDeletions() async {
    final pending = await db.select(db.pendingDeletions).get();
    for (var d in pending) {
      try {
        // Table names in Supabase are sometimes different (e.g. mortality vs mortalities)
        String remoteTable = d.targetTableName;
        if (remoteTable == 'mortalities') remoteTable = 'mortality';
        if (remoteTable == 'feeding_logs') remoteTable = 'daily_feeding_logs';
        if (remoteTable == 'egg_productions') remoteTable = 'egg_production';

        await _supabase.from(remoteTable).delete().eq('id', d.recordId);
        await (db.delete(db.pendingDeletions)..where((t) => t.id.equals(d.id))).go();
        debugPrint("Deleted remote record: $remoteTable ID ${d.recordId}");
      } catch (e) {
        debugPrint("Deletion sync error for ${d.targetTableName} ID ${d.recordId}: $e");
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
          growthTarget: Value(rb['growth_target']?.toString()),
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
          supplyItems: Value(c['supplyItems'] as String?),
          contactPerson: Value(c['contactPerson'] as String?),
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
          batchId: m['batch_id'] as int,
          count: m['count'] as int,
          reason: Value(m['reason'] as String?),
          category: Value(m['category'] as String?),
          subCategory: Value(m['sub_category'] as String?),
          logDate: DateTime.parse(m['logDate'] as String),
          userId: Value(m['user_id'] as String?),
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

      // 8. Pull Feed Types
      final remoteFT = await _supabase.from('feed_types').select().eq('farmId', farmId);
      for (var ft in remoteFT) {
        await db.into(db.feedTypes).insertOnConflictUpdate(FeedTypesCompanion.insert(
          id: Value(ft['id']),
          farmId: farmId,
          name: ft['name'],
          currentStock: Value(double.parse(ft['currentStock'].toString())),
          costPerKg: Value(double.parse(ft['costPerKg'].toString())),
          synced: const Value(true),
        ));
      }

      // 10. Pull Users and Farm Members
      final teamData = await _supabase.from('users').select('*, farm_members(*)').eq('farm_members.farmId', farmId);
      for (var u in teamData) {
        final userId = u['id'] as String;
        await db.into(db.users).insertOnConflictUpdate(UsersCompanion.insert(
          id: userId,
          firstname: Value(u['firstname'] as String?),
          surname: Value(u['surname'] as String?),
          middleName: Value(u['middle_name'] as String?),
          name: Value(u['name'] as String?),
          email: Value(u['email'] as String?),
          phoneNumber: Value(u['phone_number'] as String?),
          role: Value(u['role'] as String? ?? 'worker'),
          mustChangePassword: Value(u['must_change_password'] as bool? ?? false),
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

      // 11. Pull Expenses (direct)
      final rExp = await _supabase.from('expenses').select().eq('farmId', farmId);
      for (var e in rExp) {
        await db.into(db.expenses).insertOnConflictUpdate(ExpensesCompanion.insert(
          id: Value(e['id'] as int),
          farmId: farmId,
          category: e['category'] as String,
          amount: double.parse(e['amount'].toString()),
          date: Value(DateTime.parse(e['date'] as String)),
          description: Value(e['description'] as String?),
          synced: const Value(true),
        ));
      }
      debugPrint("Pull: synced ${rExp.length} expenses");

      // 12. Pull Settlements (direct)
      final rSet = await _supabase.from('settlements').select().eq('farmId', farmId);
      for (var s in rSet) {
        await db.into(db.settlements).insertOnConflictUpdate(SettlementsCompanion.insert(
          id: Value(s['id'] as int),
          farmId: farmId,
          customerId: s['customerId'] as int,
          amount: double.parse(s['amount'].toString()),
          settlementDate: Value(DateTime.parse(s['settlementDate'] as String)),
          settlementType: s['settlementType'] as String,
          synced: const Value(true),
        ));
      }
      // 13. Pull Stock Logs
      final rStock = await _supabase.from('stock_logs').select().eq('farm_id', farmId);
      for (var sl in rStock) {
        await db.into(db.stockLogs).insertOnConflictUpdate(StockLogsCompanion.insert(
          id: Value(sl['id'] as int),
          farmId: farmId,
          itemId: sl['item_id'] as int,
          quantity: double.parse(sl['quantity'].toString()),
          logType: sl['log_type'] as String,
          batchId: Value(sl['batch_id'] as int?),
          supplierId: Value(sl['supplier_id'] as int?),
          note: Value(sl['note'] as String?),
          logDate: Value(DateTime.parse(sl['log_date'] as String)),
          synced: const Value(true),
        ));
      }
      debugPrint("Pull: synced ${rStock.length} stock logs");

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
