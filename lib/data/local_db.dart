import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'local_db.g.dart';

// 1. Users Table (Aligned with Supabase)
@DataClassName('User')
class Users extends Table {
  @override
  String get tableName => 'users';
  
  TextColumn get id => text()();
  TextColumn get firstname => text().nullable()();
  TextColumn get surname => text().nullable()();
  TextColumn get middleName => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get image => text().nullable()();
  TextColumn get password => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  BoolColumn get mustChangePassword => boolean().withDefault(const Constant(false))();
  TextColumn get role => text().withDefault(const Constant('OWNER'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

// 2. Farms Table
@DataClassName('Farm')
class Farms extends Table {
  @override
  String get tableName => 'farms';
  
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get location => text().nullable()();
  IntColumn get capacity => integer()();
  TextColumn get userId => text()();
  TextColumn get subscriptionTier => text().withDefault(const Constant('FREE'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 3. Batches Table (Updated ID to Int, added missing fields)
@DataClassName('Batch')
class Batches extends Table {
  @override
  String get tableName => 'batches';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmId => integer()();
  IntColumn get houseId => integer().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get batchName => text().withDefault(const Constant('New Batch'))();
  TextColumn get type => text().withDefault(const Constant('POULTRY_BROILER'))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get breedType => text().nullable()();
  DateTimeColumn get arrivalDate => dateTime()();
  IntColumn get currentCount => integer()();
  IntColumn get initialCount => integer()();
  IntColumn get isolationCount => integer().withDefault(const Constant(0))();
  RealColumn get initialActualCost => real().nullable()();
  TextColumn get growthTarget => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 4. Inventory Table
@DataClassName('InventoryItem')
class Inventory extends Table {
  @override
  String get tableName => 'inventory';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmId => integer()();
  TextColumn get userId => text().nullable()();
  TextColumn get itemName => text()();
  RealColumn get stockLevel => real()();
  RealColumn get reorderLevel => real().nullable()();
  TextColumn get unit => text()();
  TextColumn get category => text().nullable()();
  RealColumn get costPerUnit => real().nullable()();
  IntColumn get supplierId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 5. Feeding Logs (Updated field names to camelCase but matching Supabase snake_case in sync)
@DataClassName('FeedingLog')
class FeedingLogs extends Table {
  @override
  String get tableName => 'daily_feeding_logs';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmId => integer()();
  IntColumn get batchId => integer().nullable()();
  IntColumn get feedTypeId => integer().nullable()();
  IntColumn get formulationId => integer().nullable()();
  RealColumn get amountConsumed => real()();
  DateTimeColumn get logDate => dateTime()();
  TextColumn get userId => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 6. Egg Production
@DataClassName('EggProduction')
class EggProductions extends Table {
  @override
  String get tableName => 'egg_production';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmId => integer()();
  IntColumn get batchId => integer()();
  IntColumn get categoryId => integer().nullable()();
  IntColumn get eggsCollected => integer()();
  IntColumn get unusableCount => integer().withDefault(const Constant(0))();
  IntColumn get eggsRemaining => integer().withDefault(const Constant(0))();
  RealColumn get cratesCollected => real().nullable()();
  TextColumn get qualityGrade => text().nullable()();
  DateTimeColumn get logDate => dateTime()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 7. Mortality
@DataClassName('Mortality')
class Mortalities extends Table {
  @override
  String get tableName => 'mortality';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmId => integer()();
  IntColumn get batchId => integer()();
  IntColumn get count => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get subCategory => text().nullable()();
  DateTimeColumn get logDate => dateTime()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 8. Houses
@DataClassName('House')
class Houses extends Table {
  @override
  String get tableName => 'houses';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmId => integer()();
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()();
  IntColumn get capacity => integer()();
  RealColumn get currentTemperature => real().nullable()();
  RealColumn get currentHumidity => real().nullable()();
  BoolColumn get isIsolation => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 9. Customers
@DataClassName('Customer')
class Customers extends Table {
  @override
  String get tableName => 'customers';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmId => integer()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get balanceOwed => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get customerType => text().withDefault(const Constant('CUSTOMER'))(); // 'CUSTOMER' or 'SUPPLIER'
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 10. Farm Settings
@DataClassName('FarmSetting')
class FarmSettings extends Table {
  @override
  String get tableName => 'farm_settings';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmId => integer()();
  TextColumn get currency => text().withDefault(const Constant('GHS'))();
  TextColumn get eggRecordReminderTime => text().nullable()();
  TextColumn get feedRecordReminderTime => text().nullable()();
  IntColumn get growthTargetStandard => integer().nullable()();
  IntColumn get eggsPerCrate => integer().withDefault(const Constant(30))();
  BoolColumn get synced => boolean().withDefault(const Constant(true))();
}

// 11. Weight Records
@DataClassName('WeightRecord')
class WeightRecords extends Table {
  @override
  String get tableName => 'weight_records';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmId => integer()();
  IntColumn get batchId => integer()();
  RealColumn get averageWeight => real()();
  DateTimeColumn get logDate => dateTime()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 12. Device Registrations (Hardware Binding)
@DataClassName('DeviceRegistration')
class DeviceRegistrations extends Table {
  @override
  String get tableName => 'device_registrations';
  
  TextColumn get id => text()(); // UUID as text
  IntColumn get farmId => integer()();
  TextColumn get userId => text()();
  TextColumn get deviceIdentifier => text()();
  TextColumn get deviceName => text().nullable()();
  DateTimeColumn get registeredAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

// 13. Farm Members
@DataClassName('FarmMember')
class FarmMembers extends Table {
  @override
  String get tableName => 'farm_members';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmId => integer()();
  TextColumn get userId => text()();
  TextColumn get role => text().withDefault(const Constant('WORKER'))();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 14. Feed Types
@DataClassName('FeedType')
class FeedTypes extends Table {
  @override
  String get tableName => 'feed_types';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmId => integer()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get currentStock => real().withDefault(const Constant(0.0))();
  RealColumn get costPerKg => real().withDefault(const Constant(0.0))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 15. Feed Formulations
@DataClassName('FeedFormulation')
class FeedFormulations extends Table {
  @override
  String get tableName => 'feed_formulations';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmId => integer()();
  TextColumn get name => text()();
  TextColumn get ingredientsJson => text().nullable()(); // JSON string
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 16. Vaccination Schedules
@DataClassName('VaccinationSchedule')
class VaccinationSchedules extends Table {
  @override
  String get tableName => 'vaccination_schedules';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get batchId => integer()();
  TextColumn get vaccineName => text()();
  DateTimeColumn get scheduledDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  TextColumn get notes => text().nullable()();
  IntColumn get farmId => integer()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 17. Medication Schedules
@DataClassName('MedicationSchedule')
class MedicationSchedules extends Table {
  @override
  String get tableName => 'medication_schedules';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get batchId => integer()();
  TextColumn get medicationName => text()();
  DateTimeColumn get scheduledDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  TextColumn get notes => text().nullable()();
  IntColumn get farmId => integer()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 18. Sales Table
@DataClassName('Sale')
class Sales extends Table {
  @override
  String get tableName => 'sales';
  
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmId => integer()();
  IntColumn get batchId => integer().nullable()();
  IntColumn get customerId => integer().nullable()();
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()();
  RealColumn get totalAmount => real()();
  DateTimeColumn get saleDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get userId => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

// 19. Pending Deletions (to track what needs to be deleted from cloud)
@DataClassName('PendingDeletion')
class PendingDeletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetTableName => text()();
  TextColumn get recordId => text()(); 
  IntColumn get farmId => integer()();
  DateTimeColumn get deletedAt => dateTime().withDefault(currentDateAndTime)();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'poultry_pms.sqlite'));
    
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [
  Users, 
  Farms, 
  Batches, 
  Inventory, 
  FeedingLogs, 
  EggProductions, 
  Mortalities,
  Houses,
  Customers,
  FarmSettings,
  WeightRecords,
  DeviceRegistrations,
  FarmMembers,
  FeedTypes,
  FeedFormulations,
  VaccinationSchedules,
  MedicationSchedules,
  Sales,
  PendingDeletions
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 10) {
            for (final table in allTables) {
              await m.drop(table);
              await m.create(table);
            }
          }
          if (from < 11) {
            await m.createTable(pendingDeletions);
          }
        },
      );
}
