// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstnameMeta = const VerificationMeta(
    'firstname',
  );
  @override
  late final GeneratedColumn<String> firstname = GeneratedColumn<String>(
    'firstname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _surnameMeta = const VerificationMeta(
    'surname',
  );
  @override
  late final GeneratedColumn<String> surname = GeneratedColumn<String>(
    'surname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _middleNameMeta = const VerificationMeta(
    'middleName',
  );
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
    'middle_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mustChangePasswordMeta =
      const VerificationMeta('mustChangePassword');
  @override
  late final GeneratedColumn<bool> mustChangePassword = GeneratedColumn<bool>(
    'must_change_password',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("must_change_password" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('OWNER'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firstname,
    surname,
    middleName,
    name,
    email,
    image,
    password,
    phoneNumber,
    mustChangePassword,
    role,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('firstname')) {
      context.handle(
        _firstnameMeta,
        firstname.isAcceptableOrUnknown(data['firstname']!, _firstnameMeta),
      );
    }
    if (data.containsKey('surname')) {
      context.handle(
        _surnameMeta,
        surname.isAcceptableOrUnknown(data['surname']!, _surnameMeta),
      );
    }
    if (data.containsKey('middle_name')) {
      context.handle(
        _middleNameMeta,
        middleName.isAcceptableOrUnknown(data['middle_name']!, _middleNameMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('must_change_password')) {
      context.handle(
        _mustChangePasswordMeta,
        mustChangePassword.isAcceptableOrUnknown(
          data['must_change_password']!,
          _mustChangePasswordMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firstname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firstname'],
      ),
      surname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surname'],
      ),
      middleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}middle_name'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      ),
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      mustChangePassword: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}must_change_password'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String? firstname;
  final String? surname;
  final String? middleName;
  final String? name;
  final String? email;
  final String? image;
  final String? password;
  final String? phoneNumber;
  final bool mustChangePassword;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  const User({
    required this.id,
    this.firstname,
    this.surname,
    this.middleName,
    this.name,
    this.email,
    this.image,
    this.password,
    this.phoneNumber,
    required this.mustChangePassword,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || firstname != null) {
      map['firstname'] = Variable<String>(firstname);
    }
    if (!nullToAbsent || surname != null) {
      map['surname'] = Variable<String>(surname);
    }
    if (!nullToAbsent || middleName != null) {
      map['middle_name'] = Variable<String>(middleName);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<String>(image);
    }
    if (!nullToAbsent || password != null) {
      map['password'] = Variable<String>(password);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    map['must_change_password'] = Variable<bool>(mustChangePassword);
    map['role'] = Variable<String>(role);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      firstname: firstname == null && nullToAbsent
          ? const Value.absent()
          : Value(firstname),
      surname: surname == null && nullToAbsent
          ? const Value.absent()
          : Value(surname),
      middleName: middleName == null && nullToAbsent
          ? const Value.absent()
          : Value(middleName),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      image: image == null && nullToAbsent
          ? const Value.absent()
          : Value(image),
      password: password == null && nullToAbsent
          ? const Value.absent()
          : Value(password),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      mustChangePassword: Value(mustChangePassword),
      role: Value(role),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      firstname: serializer.fromJson<String?>(json['firstname']),
      surname: serializer.fromJson<String?>(json['surname']),
      middleName: serializer.fromJson<String?>(json['middleName']),
      name: serializer.fromJson<String?>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      image: serializer.fromJson<String?>(json['image']),
      password: serializer.fromJson<String?>(json['password']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      mustChangePassword: serializer.fromJson<bool>(json['mustChangePassword']),
      role: serializer.fromJson<String>(json['role']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firstname': serializer.toJson<String?>(firstname),
      'surname': serializer.toJson<String?>(surname),
      'middleName': serializer.toJson<String?>(middleName),
      'name': serializer.toJson<String?>(name),
      'email': serializer.toJson<String?>(email),
      'image': serializer.toJson<String?>(image),
      'password': serializer.toJson<String?>(password),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'mustChangePassword': serializer.toJson<bool>(mustChangePassword),
      'role': serializer.toJson<String>(role),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  User copyWith({
    String? id,
    Value<String?> firstname = const Value.absent(),
    Value<String?> surname = const Value.absent(),
    Value<String?> middleName = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> image = const Value.absent(),
    Value<String?> password = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
    bool? mustChangePassword,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    firstname: firstname.present ? firstname.value : this.firstname,
    surname: surname.present ? surname.value : this.surname,
    middleName: middleName.present ? middleName.value : this.middleName,
    name: name.present ? name.value : this.name,
    email: email.present ? email.value : this.email,
    image: image.present ? image.value : this.image,
    password: password.present ? password.value : this.password,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      firstname: data.firstname.present ? data.firstname.value : this.firstname,
      surname: data.surname.present ? data.surname.value : this.surname,
      middleName: data.middleName.present
          ? data.middleName.value
          : this.middleName,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      image: data.image.present ? data.image.value : this.image,
      password: data.password.present ? data.password.value : this.password,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      mustChangePassword: data.mustChangePassword.present
          ? data.mustChangePassword.value
          : this.mustChangePassword,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('firstname: $firstname, ')
          ..write('surname: $surname, ')
          ..write('middleName: $middleName, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('image: $image, ')
          ..write('password: $password, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('mustChangePassword: $mustChangePassword, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firstname,
    surname,
    middleName,
    name,
    email,
    image,
    password,
    phoneNumber,
    mustChangePassword,
    role,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.firstname == this.firstname &&
          other.surname == this.surname &&
          other.middleName == this.middleName &&
          other.name == this.name &&
          other.email == this.email &&
          other.image == this.image &&
          other.password == this.password &&
          other.phoneNumber == this.phoneNumber &&
          other.mustChangePassword == this.mustChangePassword &&
          other.role == this.role &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String?> firstname;
  final Value<String?> surname;
  final Value<String?> middleName;
  final Value<String?> name;
  final Value<String?> email;
  final Value<String?> image;
  final Value<String?> password;
  final Value<String?> phoneNumber;
  final Value<bool> mustChangePassword;
  final Value<String> role;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.firstname = const Value.absent(),
    this.surname = const Value.absent(),
    this.middleName = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.image = const Value.absent(),
    this.password = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.mustChangePassword = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    this.firstname = const Value.absent(),
    this.surname = const Value.absent(),
    this.middleName = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.image = const Value.absent(),
    this.password = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.mustChangePassword = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? firstname,
    Expression<String>? surname,
    Expression<String>? middleName,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? image,
    Expression<String>? password,
    Expression<String>? phoneNumber,
    Expression<bool>? mustChangePassword,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstname != null) 'firstname': firstname,
      if (surname != null) 'surname': surname,
      if (middleName != null) 'middle_name': middleName,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (image != null) 'image': image,
      if (password != null) 'password': password,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (mustChangePassword != null)
        'must_change_password': mustChangePassword,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String?>? firstname,
    Value<String?>? surname,
    Value<String?>? middleName,
    Value<String?>? name,
    Value<String?>? email,
    Value<String?>? image,
    Value<String?>? password,
    Value<String?>? phoneNumber,
    Value<bool>? mustChangePassword,
    Value<String>? role,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      surname: surname ?? this.surname,
      middleName: middleName ?? this.middleName,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firstname.present) {
      map['firstname'] = Variable<String>(firstname.value);
    }
    if (surname.present) {
      map['surname'] = Variable<String>(surname.value);
    }
    if (middleName.present) {
      map['middle_name'] = Variable<String>(middleName.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (mustChangePassword.present) {
      map['must_change_password'] = Variable<bool>(mustChangePassword.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('firstname: $firstname, ')
          ..write('surname: $surname, ')
          ..write('middleName: $middleName, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('image: $image, ')
          ..write('password: $password, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('mustChangePassword: $mustChangePassword, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmsTable extends Farms with TableInfo<$FarmsTable, Farm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subscriptionTierMeta = const VerificationMeta(
    'subscriptionTier',
  );
  @override
  late final GeneratedColumn<String> subscriptionTier = GeneratedColumn<String>(
    'subscription_tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('FREE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    location,
    capacity,
    userId,
    subscriptionTier,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Farm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    } else if (isInserting) {
      context.missing(_capacityMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('subscription_tier')) {
      context.handle(
        _subscriptionTierMeta,
        subscriptionTier.isAcceptableOrUnknown(
          data['subscription_tier']!,
          _subscriptionTierMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Farm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Farm(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      subscriptionTier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscription_tier'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FarmsTable createAlias(String alias) {
    return $FarmsTable(attachedDatabase, alias);
  }
}

class Farm extends DataClass implements Insertable<Farm> {
  final int id;
  final String name;
  final String? location;
  final int capacity;
  final String userId;
  final String subscriptionTier;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Farm({
    required this.id,
    required this.name,
    this.location,
    required this.capacity,
    required this.userId,
    required this.subscriptionTier,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['capacity'] = Variable<int>(capacity);
    map['user_id'] = Variable<String>(userId);
    map['subscription_tier'] = Variable<String>(subscriptionTier);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FarmsCompanion toCompanion(bool nullToAbsent) {
    return FarmsCompanion(
      id: Value(id),
      name: Value(name),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      capacity: Value(capacity),
      userId: Value(userId),
      subscriptionTier: Value(subscriptionTier),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Farm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Farm(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String?>(json['location']),
      capacity: serializer.fromJson<int>(json['capacity']),
      userId: serializer.fromJson<String>(json['userId']),
      subscriptionTier: serializer.fromJson<String>(json['subscriptionTier']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String?>(location),
      'capacity': serializer.toJson<int>(capacity),
      'userId': serializer.toJson<String>(userId),
      'subscriptionTier': serializer.toJson<String>(subscriptionTier),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Farm copyWith({
    int? id,
    String? name,
    Value<String?> location = const Value.absent(),
    int? capacity,
    String? userId,
    String? subscriptionTier,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Farm(
    id: id ?? this.id,
    name: name ?? this.name,
    location: location.present ? location.value : this.location,
    capacity: capacity ?? this.capacity,
    userId: userId ?? this.userId,
    subscriptionTier: subscriptionTier ?? this.subscriptionTier,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Farm copyWithCompanion(FarmsCompanion data) {
    return Farm(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      userId: data.userId.present ? data.userId.value : this.userId,
      subscriptionTier: data.subscriptionTier.present
          ? data.subscriptionTier.value
          : this.subscriptionTier,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Farm(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('capacity: $capacity, ')
          ..write('userId: $userId, ')
          ..write('subscriptionTier: $subscriptionTier, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    location,
    capacity,
    userId,
    subscriptionTier,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Farm &&
          other.id == this.id &&
          other.name == this.name &&
          other.location == this.location &&
          other.capacity == this.capacity &&
          other.userId == this.userId &&
          other.subscriptionTier == this.subscriptionTier &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FarmsCompanion extends UpdateCompanion<Farm> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> location;
  final Value<int> capacity;
  final Value<String> userId;
  final Value<String> subscriptionTier;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const FarmsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.capacity = const Value.absent(),
    this.userId = const Value.absent(),
    this.subscriptionTier = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FarmsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.location = const Value.absent(),
    required int capacity,
    required String userId,
    this.subscriptionTier = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       capacity = Value(capacity),
       userId = Value(userId);
  static Insertable<Farm> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? location,
    Expression<int>? capacity,
    Expression<String>? userId,
    Expression<String>? subscriptionTier,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (capacity != null) 'capacity': capacity,
      if (userId != null) 'user_id': userId,
      if (subscriptionTier != null) 'subscription_tier': subscriptionTier,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FarmsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? location,
    Value<int>? capacity,
    Value<String>? userId,
    Value<String>? subscriptionTier,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return FarmsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      userId: userId ?? this.userId,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (subscriptionTier.present) {
      map['subscription_tier'] = Variable<String>(subscriptionTier.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('capacity: $capacity, ')
          ..write('userId: $userId, ')
          ..write('subscriptionTier: $subscriptionTier, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BatchesTable extends Batches with TableInfo<$BatchesTable, Batch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<int> houseId = GeneratedColumn<int>(
    'house_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchNameMeta = const VerificationMeta(
    'batchName',
  );
  @override
  late final GeneratedColumn<String> batchName = GeneratedColumn<String>(
    'batch_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('New Batch'),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('POULTRY_BROILER'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _breedTypeMeta = const VerificationMeta(
    'breedType',
  );
  @override
  late final GeneratedColumn<String> breedType = GeneratedColumn<String>(
    'breed_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arrivalDateMeta = const VerificationMeta(
    'arrivalDate',
  );
  @override
  late final GeneratedColumn<DateTime> arrivalDate = GeneratedColumn<DateTime>(
    'arrival_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentCountMeta = const VerificationMeta(
    'currentCount',
  );
  @override
  late final GeneratedColumn<int> currentCount = GeneratedColumn<int>(
    'current_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialCountMeta = const VerificationMeta(
    'initialCount',
  );
  @override
  late final GeneratedColumn<int> initialCount = GeneratedColumn<int>(
    'initial_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isolationCountMeta = const VerificationMeta(
    'isolationCount',
  );
  @override
  late final GeneratedColumn<int> isolationCount = GeneratedColumn<int>(
    'isolation_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _initialActualCostMeta = const VerificationMeta(
    'initialActualCost',
  );
  @override
  late final GeneratedColumn<double> initialActualCost =
      GeneratedColumn<double>(
        'initial_actual_cost',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _growthTargetMeta = const VerificationMeta(
    'growthTarget',
  );
  @override
  late final GeneratedColumn<String> growthTarget = GeneratedColumn<String>(
    'growth_target',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    houseId,
    userId,
    batchName,
    type,
    status,
    breedType,
    arrivalDate,
    currentCount,
    initialCount,
    isolationCount,
    initialActualCost,
    growthTarget,
    createdAt,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Batch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('batch_name')) {
      context.handle(
        _batchNameMeta,
        batchName.isAcceptableOrUnknown(data['batch_name']!, _batchNameMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('breed_type')) {
      context.handle(
        _breedTypeMeta,
        breedType.isAcceptableOrUnknown(data['breed_type']!, _breedTypeMeta),
      );
    }
    if (data.containsKey('arrival_date')) {
      context.handle(
        _arrivalDateMeta,
        arrivalDate.isAcceptableOrUnknown(
          data['arrival_date']!,
          _arrivalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalDateMeta);
    }
    if (data.containsKey('current_count')) {
      context.handle(
        _currentCountMeta,
        currentCount.isAcceptableOrUnknown(
          data['current_count']!,
          _currentCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentCountMeta);
    }
    if (data.containsKey('initial_count')) {
      context.handle(
        _initialCountMeta,
        initialCount.isAcceptableOrUnknown(
          data['initial_count']!,
          _initialCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialCountMeta);
    }
    if (data.containsKey('isolation_count')) {
      context.handle(
        _isolationCountMeta,
        isolationCount.isAcceptableOrUnknown(
          data['isolation_count']!,
          _isolationCountMeta,
        ),
      );
    }
    if (data.containsKey('initial_actual_cost')) {
      context.handle(
        _initialActualCostMeta,
        initialActualCost.isAcceptableOrUnknown(
          data['initial_actual_cost']!,
          _initialActualCostMeta,
        ),
      );
    }
    if (data.containsKey('growth_target')) {
      context.handle(
        _growthTargetMeta,
        growthTarget.isAcceptableOrUnknown(
          data['growth_target']!,
          _growthTargetMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Batch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Batch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}house_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      batchName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      breedType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed_type'],
      ),
      arrivalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arrival_date'],
      )!,
      currentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_count'],
      )!,
      initialCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_count'],
      )!,
      isolationCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}isolation_count'],
      )!,
      initialActualCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_actual_cost'],
      ),
      growthTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}growth_target'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $BatchesTable createAlias(String alias) {
    return $BatchesTable(attachedDatabase, alias);
  }
}

class Batch extends DataClass implements Insertable<Batch> {
  final int id;
  final int farmId;
  final int? houseId;
  final String? userId;
  final String batchName;
  final String type;
  final String status;
  final String? breedType;
  final DateTime arrivalDate;
  final int currentCount;
  final int initialCount;
  final int isolationCount;
  final double? initialActualCost;
  final String? growthTarget;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const Batch({
    required this.id,
    required this.farmId,
    this.houseId,
    this.userId,
    required this.batchName,
    required this.type,
    required this.status,
    this.breedType,
    required this.arrivalDate,
    required this.currentCount,
    required this.initialCount,
    required this.isolationCount,
    this.initialActualCost,
    this.growthTarget,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farm_id'] = Variable<int>(farmId);
    if (!nullToAbsent || houseId != null) {
      map['house_id'] = Variable<int>(houseId);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['batch_name'] = Variable<String>(batchName);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || breedType != null) {
      map['breed_type'] = Variable<String>(breedType);
    }
    map['arrival_date'] = Variable<DateTime>(arrivalDate);
    map['current_count'] = Variable<int>(currentCount);
    map['initial_count'] = Variable<int>(initialCount);
    map['isolation_count'] = Variable<int>(isolationCount);
    if (!nullToAbsent || initialActualCost != null) {
      map['initial_actual_cost'] = Variable<double>(initialActualCost);
    }
    if (!nullToAbsent || growthTarget != null) {
      map['growth_target'] = Variable<String>(growthTarget);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  BatchesCompanion toCompanion(bool nullToAbsent) {
    return BatchesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      houseId: houseId == null && nullToAbsent
          ? const Value.absent()
          : Value(houseId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      batchName: Value(batchName),
      type: Value(type),
      status: Value(status),
      breedType: breedType == null && nullToAbsent
          ? const Value.absent()
          : Value(breedType),
      arrivalDate: Value(arrivalDate),
      currentCount: Value(currentCount),
      initialCount: Value(initialCount),
      isolationCount: Value(isolationCount),
      initialActualCost: initialActualCost == null && nullToAbsent
          ? const Value.absent()
          : Value(initialActualCost),
      growthTarget: growthTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(growthTarget),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory Batch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Batch(
      id: serializer.fromJson<int>(json['id']),
      farmId: serializer.fromJson<int>(json['farmId']),
      houseId: serializer.fromJson<int?>(json['houseId']),
      userId: serializer.fromJson<String?>(json['userId']),
      batchName: serializer.fromJson<String>(json['batchName']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      breedType: serializer.fromJson<String?>(json['breedType']),
      arrivalDate: serializer.fromJson<DateTime>(json['arrivalDate']),
      currentCount: serializer.fromJson<int>(json['currentCount']),
      initialCount: serializer.fromJson<int>(json['initialCount']),
      isolationCount: serializer.fromJson<int>(json['isolationCount']),
      initialActualCost: serializer.fromJson<double?>(
        json['initialActualCost'],
      ),
      growthTarget: serializer.fromJson<String?>(json['growthTarget']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmId': serializer.toJson<int>(farmId),
      'houseId': serializer.toJson<int?>(houseId),
      'userId': serializer.toJson<String?>(userId),
      'batchName': serializer.toJson<String>(batchName),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'breedType': serializer.toJson<String?>(breedType),
      'arrivalDate': serializer.toJson<DateTime>(arrivalDate),
      'currentCount': serializer.toJson<int>(currentCount),
      'initialCount': serializer.toJson<int>(initialCount),
      'isolationCount': serializer.toJson<int>(isolationCount),
      'initialActualCost': serializer.toJson<double?>(initialActualCost),
      'growthTarget': serializer.toJson<String?>(growthTarget),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Batch copyWith({
    int? id,
    int? farmId,
    Value<int?> houseId = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    String? batchName,
    String? type,
    String? status,
    Value<String?> breedType = const Value.absent(),
    DateTime? arrivalDate,
    int? currentCount,
    int? initialCount,
    int? isolationCount,
    Value<double?> initialActualCost = const Value.absent(),
    Value<String?> growthTarget = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) => Batch(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    houseId: houseId.present ? houseId.value : this.houseId,
    userId: userId.present ? userId.value : this.userId,
    batchName: batchName ?? this.batchName,
    type: type ?? this.type,
    status: status ?? this.status,
    breedType: breedType.present ? breedType.value : this.breedType,
    arrivalDate: arrivalDate ?? this.arrivalDate,
    currentCount: currentCount ?? this.currentCount,
    initialCount: initialCount ?? this.initialCount,
    isolationCount: isolationCount ?? this.isolationCount,
    initialActualCost: initialActualCost.present
        ? initialActualCost.value
        : this.initialActualCost,
    growthTarget: growthTarget.present ? growthTarget.value : this.growthTarget,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  Batch copyWithCompanion(BatchesCompanion data) {
    return Batch(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      userId: data.userId.present ? data.userId.value : this.userId,
      batchName: data.batchName.present ? data.batchName.value : this.batchName,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      breedType: data.breedType.present ? data.breedType.value : this.breedType,
      arrivalDate: data.arrivalDate.present
          ? data.arrivalDate.value
          : this.arrivalDate,
      currentCount: data.currentCount.present
          ? data.currentCount.value
          : this.currentCount,
      initialCount: data.initialCount.present
          ? data.initialCount.value
          : this.initialCount,
      isolationCount: data.isolationCount.present
          ? data.isolationCount.value
          : this.isolationCount,
      initialActualCost: data.initialActualCost.present
          ? data.initialActualCost.value
          : this.initialActualCost,
      growthTarget: data.growthTarget.present
          ? data.growthTarget.value
          : this.growthTarget,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Batch(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('houseId: $houseId, ')
          ..write('userId: $userId, ')
          ..write('batchName: $batchName, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('breedType: $breedType, ')
          ..write('arrivalDate: $arrivalDate, ')
          ..write('currentCount: $currentCount, ')
          ..write('initialCount: $initialCount, ')
          ..write('isolationCount: $isolationCount, ')
          ..write('initialActualCost: $initialActualCost, ')
          ..write('growthTarget: $growthTarget, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    houseId,
    userId,
    batchName,
    type,
    status,
    breedType,
    arrivalDate,
    currentCount,
    initialCount,
    isolationCount,
    initialActualCost,
    growthTarget,
    createdAt,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Batch &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.houseId == this.houseId &&
          other.userId == this.userId &&
          other.batchName == this.batchName &&
          other.type == this.type &&
          other.status == this.status &&
          other.breedType == this.breedType &&
          other.arrivalDate == this.arrivalDate &&
          other.currentCount == this.currentCount &&
          other.initialCount == this.initialCount &&
          other.isolationCount == this.isolationCount &&
          other.initialActualCost == this.initialActualCost &&
          other.growthTarget == this.growthTarget &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class BatchesCompanion extends UpdateCompanion<Batch> {
  final Value<int> id;
  final Value<int> farmId;
  final Value<int?> houseId;
  final Value<String?> userId;
  final Value<String> batchName;
  final Value<String> type;
  final Value<String> status;
  final Value<String?> breedType;
  final Value<DateTime> arrivalDate;
  final Value<int> currentCount;
  final Value<int> initialCount;
  final Value<int> isolationCount;
  final Value<double?> initialActualCost;
  final Value<String?> growthTarget;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  const BatchesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.houseId = const Value.absent(),
    this.userId = const Value.absent(),
    this.batchName = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.breedType = const Value.absent(),
    this.arrivalDate = const Value.absent(),
    this.currentCount = const Value.absent(),
    this.initialCount = const Value.absent(),
    this.isolationCount = const Value.absent(),
    this.initialActualCost = const Value.absent(),
    this.growthTarget = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  BatchesCompanion.insert({
    this.id = const Value.absent(),
    required int farmId,
    this.houseId = const Value.absent(),
    this.userId = const Value.absent(),
    this.batchName = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.breedType = const Value.absent(),
    required DateTime arrivalDate,
    required int currentCount,
    required int initialCount,
    this.isolationCount = const Value.absent(),
    this.initialActualCost = const Value.absent(),
    this.growthTarget = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
  }) : farmId = Value(farmId),
       arrivalDate = Value(arrivalDate),
       currentCount = Value(currentCount),
       initialCount = Value(initialCount);
  static Insertable<Batch> custom({
    Expression<int>? id,
    Expression<int>? farmId,
    Expression<int>? houseId,
    Expression<String>? userId,
    Expression<String>? batchName,
    Expression<String>? type,
    Expression<String>? status,
    Expression<String>? breedType,
    Expression<DateTime>? arrivalDate,
    Expression<int>? currentCount,
    Expression<int>? initialCount,
    Expression<int>? isolationCount,
    Expression<double>? initialActualCost,
    Expression<String>? growthTarget,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (houseId != null) 'house_id': houseId,
      if (userId != null) 'user_id': userId,
      if (batchName != null) 'batch_name': batchName,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (breedType != null) 'breed_type': breedType,
      if (arrivalDate != null) 'arrival_date': arrivalDate,
      if (currentCount != null) 'current_count': currentCount,
      if (initialCount != null) 'initial_count': initialCount,
      if (isolationCount != null) 'isolation_count': isolationCount,
      if (initialActualCost != null) 'initial_actual_cost': initialActualCost,
      if (growthTarget != null) 'growth_target': growthTarget,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
    });
  }

  BatchesCompanion copyWith({
    Value<int>? id,
    Value<int>? farmId,
    Value<int?>? houseId,
    Value<String?>? userId,
    Value<String>? batchName,
    Value<String>? type,
    Value<String>? status,
    Value<String?>? breedType,
    Value<DateTime>? arrivalDate,
    Value<int>? currentCount,
    Value<int>? initialCount,
    Value<int>? isolationCount,
    Value<double?>? initialActualCost,
    Value<String?>? growthTarget,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
  }) {
    return BatchesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      houseId: houseId ?? this.houseId,
      userId: userId ?? this.userId,
      batchName: batchName ?? this.batchName,
      type: type ?? this.type,
      status: status ?? this.status,
      breedType: breedType ?? this.breedType,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      currentCount: currentCount ?? this.currentCount,
      initialCount: initialCount ?? this.initialCount,
      isolationCount: isolationCount ?? this.isolationCount,
      initialActualCost: initialActualCost ?? this.initialActualCost,
      growthTarget: growthTarget ?? this.growthTarget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<int>(houseId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (batchName.present) {
      map['batch_name'] = Variable<String>(batchName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (breedType.present) {
      map['breed_type'] = Variable<String>(breedType.value);
    }
    if (arrivalDate.present) {
      map['arrival_date'] = Variable<DateTime>(arrivalDate.value);
    }
    if (currentCount.present) {
      map['current_count'] = Variable<int>(currentCount.value);
    }
    if (initialCount.present) {
      map['initial_count'] = Variable<int>(initialCount.value);
    }
    if (isolationCount.present) {
      map['isolation_count'] = Variable<int>(isolationCount.value);
    }
    if (initialActualCost.present) {
      map['initial_actual_cost'] = Variable<double>(initialActualCost.value);
    }
    if (growthTarget.present) {
      map['growth_target'] = Variable<String>(growthTarget.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('houseId: $houseId, ')
          ..write('userId: $userId, ')
          ..write('batchName: $batchName, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('breedType: $breedType, ')
          ..write('arrivalDate: $arrivalDate, ')
          ..write('currentCount: $currentCount, ')
          ..write('initialCount: $initialCount, ')
          ..write('isolationCount: $isolationCount, ')
          ..write('initialActualCost: $initialActualCost, ')
          ..write('growthTarget: $growthTarget, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $InventoryTable extends Inventory
    with TableInfo<$InventoryTable, InventoryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemNameMeta = const VerificationMeta(
    'itemName',
  );
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
    'item_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockLevelMeta = const VerificationMeta(
    'stockLevel',
  );
  @override
  late final GeneratedColumn<double> stockLevel = GeneratedColumn<double>(
    'stock_level',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reorderLevelMeta = const VerificationMeta(
    'reorderLevel',
  );
  @override
  late final GeneratedColumn<double> reorderLevel = GeneratedColumn<double>(
    'reorder_level',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costPerUnitMeta = const VerificationMeta(
    'costPerUnit',
  );
  @override
  late final GeneratedColumn<double> costPerUnit = GeneratedColumn<double>(
    'cost_per_unit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<int> supplierId = GeneratedColumn<int>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    userId,
    itemName,
    stockLevel,
    reorderLevel,
    unit,
    category,
    costPerUnit,
    supplierId,
    createdAt,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('item_name')) {
      context.handle(
        _itemNameMeta,
        itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta),
      );
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('stock_level')) {
      context.handle(
        _stockLevelMeta,
        stockLevel.isAcceptableOrUnknown(data['stock_level']!, _stockLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_stockLevelMeta);
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
        _reorderLevelMeta,
        reorderLevel.isAcceptableOrUnknown(
          data['reorder_level']!,
          _reorderLevelMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('cost_per_unit')) {
      context.handle(
        _costPerUnitMeta,
        costPerUnit.isAcceptableOrUnknown(
          data['cost_per_unit']!,
          _costPerUnitMeta,
        ),
      );
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      itemName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_name'],
      )!,
      stockLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_level'],
      )!,
      reorderLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reorder_level'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      costPerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_per_unit'],
      ),
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}supplier_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $InventoryTable createAlias(String alias) {
    return $InventoryTable(attachedDatabase, alias);
  }
}

class InventoryItem extends DataClass implements Insertable<InventoryItem> {
  final int id;
  final int farmId;
  final String? userId;
  final String itemName;
  final double stockLevel;
  final double? reorderLevel;
  final String unit;
  final String? category;
  final double? costPerUnit;
  final int? supplierId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const InventoryItem({
    required this.id,
    required this.farmId,
    this.userId,
    required this.itemName,
    required this.stockLevel,
    this.reorderLevel,
    required this.unit,
    this.category,
    this.costPerUnit,
    this.supplierId,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farm_id'] = Variable<int>(farmId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['item_name'] = Variable<String>(itemName);
    map['stock_level'] = Variable<double>(stockLevel);
    if (!nullToAbsent || reorderLevel != null) {
      map['reorder_level'] = Variable<double>(reorderLevel);
    }
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || costPerUnit != null) {
      map['cost_per_unit'] = Variable<double>(costPerUnit);
    }
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<int>(supplierId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  InventoryCompanion toCompanion(bool nullToAbsent) {
    return InventoryCompanion(
      id: Value(id),
      farmId: Value(farmId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      itemName: Value(itemName),
      stockLevel: Value(stockLevel),
      reorderLevel: reorderLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(reorderLevel),
      unit: Value(unit),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      costPerUnit: costPerUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(costPerUnit),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory InventoryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryItem(
      id: serializer.fromJson<int>(json['id']),
      farmId: serializer.fromJson<int>(json['farmId']),
      userId: serializer.fromJson<String?>(json['userId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      stockLevel: serializer.fromJson<double>(json['stockLevel']),
      reorderLevel: serializer.fromJson<double?>(json['reorderLevel']),
      unit: serializer.fromJson<String>(json['unit']),
      category: serializer.fromJson<String?>(json['category']),
      costPerUnit: serializer.fromJson<double?>(json['costPerUnit']),
      supplierId: serializer.fromJson<int?>(json['supplierId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmId': serializer.toJson<int>(farmId),
      'userId': serializer.toJson<String?>(userId),
      'itemName': serializer.toJson<String>(itemName),
      'stockLevel': serializer.toJson<double>(stockLevel),
      'reorderLevel': serializer.toJson<double?>(reorderLevel),
      'unit': serializer.toJson<String>(unit),
      'category': serializer.toJson<String?>(category),
      'costPerUnit': serializer.toJson<double?>(costPerUnit),
      'supplierId': serializer.toJson<int?>(supplierId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  InventoryItem copyWith({
    int? id,
    int? farmId,
    Value<String?> userId = const Value.absent(),
    String? itemName,
    double? stockLevel,
    Value<double?> reorderLevel = const Value.absent(),
    String? unit,
    Value<String?> category = const Value.absent(),
    Value<double?> costPerUnit = const Value.absent(),
    Value<int?> supplierId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) => InventoryItem(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    userId: userId.present ? userId.value : this.userId,
    itemName: itemName ?? this.itemName,
    stockLevel: stockLevel ?? this.stockLevel,
    reorderLevel: reorderLevel.present ? reorderLevel.value : this.reorderLevel,
    unit: unit ?? this.unit,
    category: category.present ? category.value : this.category,
    costPerUnit: costPerUnit.present ? costPerUnit.value : this.costPerUnit,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  InventoryItem copyWithCompanion(InventoryCompanion data) {
    return InventoryItem(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      userId: data.userId.present ? data.userId.value : this.userId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      stockLevel: data.stockLevel.present
          ? data.stockLevel.value
          : this.stockLevel,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
      unit: data.unit.present ? data.unit.value : this.unit,
      category: data.category.present ? data.category.value : this.category,
      costPerUnit: data.costPerUnit.present
          ? data.costPerUnit.value
          : this.costPerUnit,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryItem(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('itemName: $itemName, ')
          ..write('stockLevel: $stockLevel, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('supplierId: $supplierId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    userId,
    itemName,
    stockLevel,
    reorderLevel,
    unit,
    category,
    costPerUnit,
    supplierId,
    createdAt,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryItem &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.userId == this.userId &&
          other.itemName == this.itemName &&
          other.stockLevel == this.stockLevel &&
          other.reorderLevel == this.reorderLevel &&
          other.unit == this.unit &&
          other.category == this.category &&
          other.costPerUnit == this.costPerUnit &&
          other.supplierId == this.supplierId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class InventoryCompanion extends UpdateCompanion<InventoryItem> {
  final Value<int> id;
  final Value<int> farmId;
  final Value<String?> userId;
  final Value<String> itemName;
  final Value<double> stockLevel;
  final Value<double?> reorderLevel;
  final Value<String> unit;
  final Value<String?> category;
  final Value<double?> costPerUnit;
  final Value<int?> supplierId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  const InventoryCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.userId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.stockLevel = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  InventoryCompanion.insert({
    this.id = const Value.absent(),
    required int farmId,
    this.userId = const Value.absent(),
    required String itemName,
    required double stockLevel,
    this.reorderLevel = const Value.absent(),
    required String unit,
    this.category = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
  }) : farmId = Value(farmId),
       itemName = Value(itemName),
       stockLevel = Value(stockLevel),
       unit = Value(unit);
  static Insertable<InventoryItem> custom({
    Expression<int>? id,
    Expression<int>? farmId,
    Expression<String>? userId,
    Expression<String>? itemName,
    Expression<double>? stockLevel,
    Expression<double>? reorderLevel,
    Expression<String>? unit,
    Expression<String>? category,
    Expression<double>? costPerUnit,
    Expression<int>? supplierId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (itemName != null) 'item_name': itemName,
      if (stockLevel != null) 'stock_level': stockLevel,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (unit != null) 'unit': unit,
      if (category != null) 'category': category,
      if (costPerUnit != null) 'cost_per_unit': costPerUnit,
      if (supplierId != null) 'supplier_id': supplierId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
    });
  }

  InventoryCompanion copyWith({
    Value<int>? id,
    Value<int>? farmId,
    Value<String?>? userId,
    Value<String>? itemName,
    Value<double>? stockLevel,
    Value<double?>? reorderLevel,
    Value<String>? unit,
    Value<String?>? category,
    Value<double?>? costPerUnit,
    Value<int?>? supplierId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
  }) {
    return InventoryCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      userId: userId ?? this.userId,
      itemName: itemName ?? this.itemName,
      stockLevel: stockLevel ?? this.stockLevel,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      supplierId: supplierId ?? this.supplierId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (stockLevel.present) {
      map['stock_level'] = Variable<double>(stockLevel.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<double>(reorderLevel.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (costPerUnit.present) {
      map['cost_per_unit'] = Variable<double>(costPerUnit.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<int>(supplierId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('itemName: $itemName, ')
          ..write('stockLevel: $stockLevel, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('supplierId: $supplierId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $FeedingLogsTable extends FeedingLogs
    with TableInfo<$FeedingLogsTable, FeedingLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedingLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feedTypeIdMeta = const VerificationMeta(
    'feedTypeId',
  );
  @override
  late final GeneratedColumn<int> feedTypeId = GeneratedColumn<int>(
    'feed_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formulationIdMeta = const VerificationMeta(
    'formulationId',
  );
  @override
  late final GeneratedColumn<int> formulationId = GeneratedColumn<int>(
    'formulation_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountConsumedMeta = const VerificationMeta(
    'amountConsumed',
  );
  @override
  late final GeneratedColumn<double> amountConsumed = GeneratedColumn<double>(
    'amount_consumed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    batchId,
    feedTypeId,
    formulationId,
    amountConsumed,
    logDate,
    userId,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_feeding_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedingLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('feed_type_id')) {
      context.handle(
        _feedTypeIdMeta,
        feedTypeId.isAcceptableOrUnknown(
          data['feed_type_id']!,
          _feedTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('formulation_id')) {
      context.handle(
        _formulationIdMeta,
        formulationId.isAcceptableOrUnknown(
          data['formulation_id']!,
          _formulationIdMeta,
        ),
      );
    }
    if (data.containsKey('amount_consumed')) {
      context.handle(
        _amountConsumedMeta,
        amountConsumed.isAcceptableOrUnknown(
          data['amount_consumed']!,
          _amountConsumedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountConsumedMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedingLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedingLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      ),
      feedTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feed_type_id'],
      ),
      formulationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}formulation_id'],
      ),
      amountConsumed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_consumed'],
      )!,
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}log_date'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $FeedingLogsTable createAlias(String alias) {
    return $FeedingLogsTable(attachedDatabase, alias);
  }
}

class FeedingLog extends DataClass implements Insertable<FeedingLog> {
  final int id;
  final int farmId;
  final int? batchId;
  final int? feedTypeId;
  final int? formulationId;
  final double amountConsumed;
  final DateTime logDate;
  final String? userId;
  final bool synced;
  const FeedingLog({
    required this.id,
    required this.farmId,
    this.batchId,
    this.feedTypeId,
    this.formulationId,
    required this.amountConsumed,
    required this.logDate,
    this.userId,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farm_id'] = Variable<int>(farmId);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<int>(batchId);
    }
    if (!nullToAbsent || feedTypeId != null) {
      map['feed_type_id'] = Variable<int>(feedTypeId);
    }
    if (!nullToAbsent || formulationId != null) {
      map['formulation_id'] = Variable<int>(formulationId);
    }
    map['amount_consumed'] = Variable<double>(amountConsumed);
    map['log_date'] = Variable<DateTime>(logDate);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  FeedingLogsCompanion toCompanion(bool nullToAbsent) {
    return FeedingLogsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      feedTypeId: feedTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(feedTypeId),
      formulationId: formulationId == null && nullToAbsent
          ? const Value.absent()
          : Value(formulationId),
      amountConsumed: Value(amountConsumed),
      logDate: Value(logDate),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      synced: Value(synced),
    );
  }

  factory FeedingLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedingLog(
      id: serializer.fromJson<int>(json['id']),
      farmId: serializer.fromJson<int>(json['farmId']),
      batchId: serializer.fromJson<int?>(json['batchId']),
      feedTypeId: serializer.fromJson<int?>(json['feedTypeId']),
      formulationId: serializer.fromJson<int?>(json['formulationId']),
      amountConsumed: serializer.fromJson<double>(json['amountConsumed']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      userId: serializer.fromJson<String?>(json['userId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmId': serializer.toJson<int>(farmId),
      'batchId': serializer.toJson<int?>(batchId),
      'feedTypeId': serializer.toJson<int?>(feedTypeId),
      'formulationId': serializer.toJson<int?>(formulationId),
      'amountConsumed': serializer.toJson<double>(amountConsumed),
      'logDate': serializer.toJson<DateTime>(logDate),
      'userId': serializer.toJson<String?>(userId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  FeedingLog copyWith({
    int? id,
    int? farmId,
    Value<int?> batchId = const Value.absent(),
    Value<int?> feedTypeId = const Value.absent(),
    Value<int?> formulationId = const Value.absent(),
    double? amountConsumed,
    DateTime? logDate,
    Value<String?> userId = const Value.absent(),
    bool? synced,
  }) => FeedingLog(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    batchId: batchId.present ? batchId.value : this.batchId,
    feedTypeId: feedTypeId.present ? feedTypeId.value : this.feedTypeId,
    formulationId: formulationId.present
        ? formulationId.value
        : this.formulationId,
    amountConsumed: amountConsumed ?? this.amountConsumed,
    logDate: logDate ?? this.logDate,
    userId: userId.present ? userId.value : this.userId,
    synced: synced ?? this.synced,
  );
  FeedingLog copyWithCompanion(FeedingLogsCompanion data) {
    return FeedingLog(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      feedTypeId: data.feedTypeId.present
          ? data.feedTypeId.value
          : this.feedTypeId,
      formulationId: data.formulationId.present
          ? data.formulationId.value
          : this.formulationId,
      amountConsumed: data.amountConsumed.present
          ? data.amountConsumed.value
          : this.amountConsumed,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedingLog(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('feedTypeId: $feedTypeId, ')
          ..write('formulationId: $formulationId, ')
          ..write('amountConsumed: $amountConsumed, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    batchId,
    feedTypeId,
    formulationId,
    amountConsumed,
    logDate,
    userId,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedingLog &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.batchId == this.batchId &&
          other.feedTypeId == this.feedTypeId &&
          other.formulationId == this.formulationId &&
          other.amountConsumed == this.amountConsumed &&
          other.logDate == this.logDate &&
          other.userId == this.userId &&
          other.synced == this.synced);
}

class FeedingLogsCompanion extends UpdateCompanion<FeedingLog> {
  final Value<int> id;
  final Value<int> farmId;
  final Value<int?> batchId;
  final Value<int?> feedTypeId;
  final Value<int?> formulationId;
  final Value<double> amountConsumed;
  final Value<DateTime> logDate;
  final Value<String?> userId;
  final Value<bool> synced;
  const FeedingLogsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.feedTypeId = const Value.absent(),
    this.formulationId = const Value.absent(),
    this.amountConsumed = const Value.absent(),
    this.logDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.synced = const Value.absent(),
  });
  FeedingLogsCompanion.insert({
    this.id = const Value.absent(),
    required int farmId,
    this.batchId = const Value.absent(),
    this.feedTypeId = const Value.absent(),
    this.formulationId = const Value.absent(),
    required double amountConsumed,
    required DateTime logDate,
    this.userId = const Value.absent(),
    this.synced = const Value.absent(),
  }) : farmId = Value(farmId),
       amountConsumed = Value(amountConsumed),
       logDate = Value(logDate);
  static Insertable<FeedingLog> custom({
    Expression<int>? id,
    Expression<int>? farmId,
    Expression<int>? batchId,
    Expression<int>? feedTypeId,
    Expression<int>? formulationId,
    Expression<double>? amountConsumed,
    Expression<DateTime>? logDate,
    Expression<String>? userId,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (batchId != null) 'batch_id': batchId,
      if (feedTypeId != null) 'feed_type_id': feedTypeId,
      if (formulationId != null) 'formulation_id': formulationId,
      if (amountConsumed != null) 'amount_consumed': amountConsumed,
      if (logDate != null) 'log_date': logDate,
      if (userId != null) 'user_id': userId,
      if (synced != null) 'synced': synced,
    });
  }

  FeedingLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? farmId,
    Value<int?>? batchId,
    Value<int?>? feedTypeId,
    Value<int?>? formulationId,
    Value<double>? amountConsumed,
    Value<DateTime>? logDate,
    Value<String?>? userId,
    Value<bool>? synced,
  }) {
    return FeedingLogsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      batchId: batchId ?? this.batchId,
      feedTypeId: feedTypeId ?? this.feedTypeId,
      formulationId: formulationId ?? this.formulationId,
      amountConsumed: amountConsumed ?? this.amountConsumed,
      logDate: logDate ?? this.logDate,
      userId: userId ?? this.userId,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (feedTypeId.present) {
      map['feed_type_id'] = Variable<int>(feedTypeId.value);
    }
    if (formulationId.present) {
      map['formulation_id'] = Variable<int>(formulationId.value);
    }
    if (amountConsumed.present) {
      map['amount_consumed'] = Variable<double>(amountConsumed.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedingLogsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('feedTypeId: $feedTypeId, ')
          ..write('formulationId: $formulationId, ')
          ..write('amountConsumed: $amountConsumed, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $EggProductionsTable extends EggProductions
    with TableInfo<$EggProductionsTable, EggProduction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EggProductionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eggsCollectedMeta = const VerificationMeta(
    'eggsCollected',
  );
  @override
  late final GeneratedColumn<int> eggsCollected = GeneratedColumn<int>(
    'eggs_collected',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unusableCountMeta = const VerificationMeta(
    'unusableCount',
  );
  @override
  late final GeneratedColumn<int> unusableCount = GeneratedColumn<int>(
    'unusable_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _eggsRemainingMeta = const VerificationMeta(
    'eggsRemaining',
  );
  @override
  late final GeneratedColumn<int> eggsRemaining = GeneratedColumn<int>(
    'eggs_remaining',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cratesCollectedMeta = const VerificationMeta(
    'cratesCollected',
  );
  @override
  late final GeneratedColumn<double> cratesCollected = GeneratedColumn<double>(
    'crates_collected',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityGradeMeta = const VerificationMeta(
    'qualityGrade',
  );
  @override
  late final GeneratedColumn<String> qualityGrade = GeneratedColumn<String>(
    'quality_grade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    batchId,
    categoryId,
    eggsCollected,
    unusableCount,
    eggsRemaining,
    cratesCollected,
    qualityGrade,
    logDate,
    userId,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'egg_production';
  @override
  VerificationContext validateIntegrity(
    Insertable<EggProduction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('eggs_collected')) {
      context.handle(
        _eggsCollectedMeta,
        eggsCollected.isAcceptableOrUnknown(
          data['eggs_collected']!,
          _eggsCollectedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eggsCollectedMeta);
    }
    if (data.containsKey('unusable_count')) {
      context.handle(
        _unusableCountMeta,
        unusableCount.isAcceptableOrUnknown(
          data['unusable_count']!,
          _unusableCountMeta,
        ),
      );
    }
    if (data.containsKey('eggs_remaining')) {
      context.handle(
        _eggsRemainingMeta,
        eggsRemaining.isAcceptableOrUnknown(
          data['eggs_remaining']!,
          _eggsRemainingMeta,
        ),
      );
    }
    if (data.containsKey('crates_collected')) {
      context.handle(
        _cratesCollectedMeta,
        cratesCollected.isAcceptableOrUnknown(
          data['crates_collected']!,
          _cratesCollectedMeta,
        ),
      );
    }
    if (data.containsKey('quality_grade')) {
      context.handle(
        _qualityGradeMeta,
        qualityGrade.isAcceptableOrUnknown(
          data['quality_grade']!,
          _qualityGradeMeta,
        ),
      );
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EggProduction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EggProduction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      eggsCollected: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eggs_collected'],
      )!,
      unusableCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unusable_count'],
      )!,
      eggsRemaining: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eggs_remaining'],
      )!,
      cratesCollected: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}crates_collected'],
      ),
      qualityGrade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality_grade'],
      ),
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}log_date'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $EggProductionsTable createAlias(String alias) {
    return $EggProductionsTable(attachedDatabase, alias);
  }
}

class EggProduction extends DataClass implements Insertable<EggProduction> {
  final int id;
  final int farmId;
  final int batchId;
  final int? categoryId;
  final int eggsCollected;
  final int unusableCount;
  final int eggsRemaining;
  final double? cratesCollected;
  final String? qualityGrade;
  final DateTime logDate;
  final String? userId;
  final DateTime createdAt;
  final bool synced;
  const EggProduction({
    required this.id,
    required this.farmId,
    required this.batchId,
    this.categoryId,
    required this.eggsCollected,
    required this.unusableCount,
    required this.eggsRemaining,
    this.cratesCollected,
    this.qualityGrade,
    required this.logDate,
    this.userId,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farm_id'] = Variable<int>(farmId);
    map['batch_id'] = Variable<int>(batchId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['eggs_collected'] = Variable<int>(eggsCollected);
    map['unusable_count'] = Variable<int>(unusableCount);
    map['eggs_remaining'] = Variable<int>(eggsRemaining);
    if (!nullToAbsent || cratesCollected != null) {
      map['crates_collected'] = Variable<double>(cratesCollected);
    }
    if (!nullToAbsent || qualityGrade != null) {
      map['quality_grade'] = Variable<String>(qualityGrade);
    }
    map['log_date'] = Variable<DateTime>(logDate);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  EggProductionsCompanion toCompanion(bool nullToAbsent) {
    return EggProductionsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      batchId: Value(batchId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      eggsCollected: Value(eggsCollected),
      unusableCount: Value(unusableCount),
      eggsRemaining: Value(eggsRemaining),
      cratesCollected: cratesCollected == null && nullToAbsent
          ? const Value.absent()
          : Value(cratesCollected),
      qualityGrade: qualityGrade == null && nullToAbsent
          ? const Value.absent()
          : Value(qualityGrade),
      logDate: Value(logDate),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory EggProduction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EggProduction(
      id: serializer.fromJson<int>(json['id']),
      farmId: serializer.fromJson<int>(json['farmId']),
      batchId: serializer.fromJson<int>(json['batchId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      eggsCollected: serializer.fromJson<int>(json['eggsCollected']),
      unusableCount: serializer.fromJson<int>(json['unusableCount']),
      eggsRemaining: serializer.fromJson<int>(json['eggsRemaining']),
      cratesCollected: serializer.fromJson<double?>(json['cratesCollected']),
      qualityGrade: serializer.fromJson<String?>(json['qualityGrade']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      userId: serializer.fromJson<String?>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmId': serializer.toJson<int>(farmId),
      'batchId': serializer.toJson<int>(batchId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'eggsCollected': serializer.toJson<int>(eggsCollected),
      'unusableCount': serializer.toJson<int>(unusableCount),
      'eggsRemaining': serializer.toJson<int>(eggsRemaining),
      'cratesCollected': serializer.toJson<double?>(cratesCollected),
      'qualityGrade': serializer.toJson<String?>(qualityGrade),
      'logDate': serializer.toJson<DateTime>(logDate),
      'userId': serializer.toJson<String?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  EggProduction copyWith({
    int? id,
    int? farmId,
    int? batchId,
    Value<int?> categoryId = const Value.absent(),
    int? eggsCollected,
    int? unusableCount,
    int? eggsRemaining,
    Value<double?> cratesCollected = const Value.absent(),
    Value<String?> qualityGrade = const Value.absent(),
    DateTime? logDate,
    Value<String?> userId = const Value.absent(),
    DateTime? createdAt,
    bool? synced,
  }) => EggProduction(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    batchId: batchId ?? this.batchId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    eggsCollected: eggsCollected ?? this.eggsCollected,
    unusableCount: unusableCount ?? this.unusableCount,
    eggsRemaining: eggsRemaining ?? this.eggsRemaining,
    cratesCollected: cratesCollected.present
        ? cratesCollected.value
        : this.cratesCollected,
    qualityGrade: qualityGrade.present ? qualityGrade.value : this.qualityGrade,
    logDate: logDate ?? this.logDate,
    userId: userId.present ? userId.value : this.userId,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  EggProduction copyWithCompanion(EggProductionsCompanion data) {
    return EggProduction(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      eggsCollected: data.eggsCollected.present
          ? data.eggsCollected.value
          : this.eggsCollected,
      unusableCount: data.unusableCount.present
          ? data.unusableCount.value
          : this.unusableCount,
      eggsRemaining: data.eggsRemaining.present
          ? data.eggsRemaining.value
          : this.eggsRemaining,
      cratesCollected: data.cratesCollected.present
          ? data.cratesCollected.value
          : this.cratesCollected,
      qualityGrade: data.qualityGrade.present
          ? data.qualityGrade.value
          : this.qualityGrade,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EggProduction(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('categoryId: $categoryId, ')
          ..write('eggsCollected: $eggsCollected, ')
          ..write('unusableCount: $unusableCount, ')
          ..write('eggsRemaining: $eggsRemaining, ')
          ..write('cratesCollected: $cratesCollected, ')
          ..write('qualityGrade: $qualityGrade, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    batchId,
    categoryId,
    eggsCollected,
    unusableCount,
    eggsRemaining,
    cratesCollected,
    qualityGrade,
    logDate,
    userId,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EggProduction &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.batchId == this.batchId &&
          other.categoryId == this.categoryId &&
          other.eggsCollected == this.eggsCollected &&
          other.unusableCount == this.unusableCount &&
          other.eggsRemaining == this.eggsRemaining &&
          other.cratesCollected == this.cratesCollected &&
          other.qualityGrade == this.qualityGrade &&
          other.logDate == this.logDate &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class EggProductionsCompanion extends UpdateCompanion<EggProduction> {
  final Value<int> id;
  final Value<int> farmId;
  final Value<int> batchId;
  final Value<int?> categoryId;
  final Value<int> eggsCollected;
  final Value<int> unusableCount;
  final Value<int> eggsRemaining;
  final Value<double?> cratesCollected;
  final Value<String?> qualityGrade;
  final Value<DateTime> logDate;
  final Value<String?> userId;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  const EggProductionsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.eggsCollected = const Value.absent(),
    this.unusableCount = const Value.absent(),
    this.eggsRemaining = const Value.absent(),
    this.cratesCollected = const Value.absent(),
    this.qualityGrade = const Value.absent(),
    this.logDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  EggProductionsCompanion.insert({
    this.id = const Value.absent(),
    required int farmId,
    required int batchId,
    this.categoryId = const Value.absent(),
    required int eggsCollected,
    this.unusableCount = const Value.absent(),
    this.eggsRemaining = const Value.absent(),
    this.cratesCollected = const Value.absent(),
    this.qualityGrade = const Value.absent(),
    required DateTime logDate,
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
  }) : farmId = Value(farmId),
       batchId = Value(batchId),
       eggsCollected = Value(eggsCollected),
       logDate = Value(logDate);
  static Insertable<EggProduction> custom({
    Expression<int>? id,
    Expression<int>? farmId,
    Expression<int>? batchId,
    Expression<int>? categoryId,
    Expression<int>? eggsCollected,
    Expression<int>? unusableCount,
    Expression<int>? eggsRemaining,
    Expression<double>? cratesCollected,
    Expression<String>? qualityGrade,
    Expression<DateTime>? logDate,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (batchId != null) 'batch_id': batchId,
      if (categoryId != null) 'category_id': categoryId,
      if (eggsCollected != null) 'eggs_collected': eggsCollected,
      if (unusableCount != null) 'unusable_count': unusableCount,
      if (eggsRemaining != null) 'eggs_remaining': eggsRemaining,
      if (cratesCollected != null) 'crates_collected': cratesCollected,
      if (qualityGrade != null) 'quality_grade': qualityGrade,
      if (logDate != null) 'log_date': logDate,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
    });
  }

  EggProductionsCompanion copyWith({
    Value<int>? id,
    Value<int>? farmId,
    Value<int>? batchId,
    Value<int?>? categoryId,
    Value<int>? eggsCollected,
    Value<int>? unusableCount,
    Value<int>? eggsRemaining,
    Value<double?>? cratesCollected,
    Value<String?>? qualityGrade,
    Value<DateTime>? logDate,
    Value<String?>? userId,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
  }) {
    return EggProductionsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      batchId: batchId ?? this.batchId,
      categoryId: categoryId ?? this.categoryId,
      eggsCollected: eggsCollected ?? this.eggsCollected,
      unusableCount: unusableCount ?? this.unusableCount,
      eggsRemaining: eggsRemaining ?? this.eggsRemaining,
      cratesCollected: cratesCollected ?? this.cratesCollected,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      logDate: logDate ?? this.logDate,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (eggsCollected.present) {
      map['eggs_collected'] = Variable<int>(eggsCollected.value);
    }
    if (unusableCount.present) {
      map['unusable_count'] = Variable<int>(unusableCount.value);
    }
    if (eggsRemaining.present) {
      map['eggs_remaining'] = Variable<int>(eggsRemaining.value);
    }
    if (cratesCollected.present) {
      map['crates_collected'] = Variable<double>(cratesCollected.value);
    }
    if (qualityGrade.present) {
      map['quality_grade'] = Variable<String>(qualityGrade.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EggProductionsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('categoryId: $categoryId, ')
          ..write('eggsCollected: $eggsCollected, ')
          ..write('unusableCount: $unusableCount, ')
          ..write('eggsRemaining: $eggsRemaining, ')
          ..write('cratesCollected: $cratesCollected, ')
          ..write('qualityGrade: $qualityGrade, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $MortalitiesTable extends Mortalities
    with TableInfo<$MortalitiesTable, Mortality> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MortalitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subCategoryMeta = const VerificationMeta(
    'subCategory',
  );
  @override
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
    'sub_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    batchId,
    count,
    reason,
    category,
    subCategory,
    logDate,
    userId,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mortality';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mortality> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('sub_category')) {
      context.handle(
        _subCategoryMeta,
        subCategory.isAcceptableOrUnknown(
          data['sub_category']!,
          _subCategoryMeta,
        ),
      );
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mortality map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mortality(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      subCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_category'],
      ),
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}log_date'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $MortalitiesTable createAlias(String alias) {
    return $MortalitiesTable(attachedDatabase, alias);
  }
}

class Mortality extends DataClass implements Insertable<Mortality> {
  final int id;
  final int farmId;
  final int batchId;
  final int count;
  final String? reason;
  final String? category;
  final String? subCategory;
  final DateTime logDate;
  final String? userId;
  final DateTime createdAt;
  final bool synced;
  const Mortality({
    required this.id,
    required this.farmId,
    required this.batchId,
    required this.count,
    this.reason,
    this.category,
    this.subCategory,
    required this.logDate,
    this.userId,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farm_id'] = Variable<int>(farmId);
    map['batch_id'] = Variable<int>(batchId);
    map['count'] = Variable<int>(count);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || subCategory != null) {
      map['sub_category'] = Variable<String>(subCategory);
    }
    map['log_date'] = Variable<DateTime>(logDate);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  MortalitiesCompanion toCompanion(bool nullToAbsent) {
    return MortalitiesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      batchId: Value(batchId),
      count: Value(count),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      subCategory: subCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subCategory),
      logDate: Value(logDate),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory Mortality.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mortality(
      id: serializer.fromJson<int>(json['id']),
      farmId: serializer.fromJson<int>(json['farmId']),
      batchId: serializer.fromJson<int>(json['batchId']),
      count: serializer.fromJson<int>(json['count']),
      reason: serializer.fromJson<String?>(json['reason']),
      category: serializer.fromJson<String?>(json['category']),
      subCategory: serializer.fromJson<String?>(json['subCategory']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      userId: serializer.fromJson<String?>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmId': serializer.toJson<int>(farmId),
      'batchId': serializer.toJson<int>(batchId),
      'count': serializer.toJson<int>(count),
      'reason': serializer.toJson<String?>(reason),
      'category': serializer.toJson<String?>(category),
      'subCategory': serializer.toJson<String?>(subCategory),
      'logDate': serializer.toJson<DateTime>(logDate),
      'userId': serializer.toJson<String?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Mortality copyWith({
    int? id,
    int? farmId,
    int? batchId,
    int? count,
    Value<String?> reason = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> subCategory = const Value.absent(),
    DateTime? logDate,
    Value<String?> userId = const Value.absent(),
    DateTime? createdAt,
    bool? synced,
  }) => Mortality(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    batchId: batchId ?? this.batchId,
    count: count ?? this.count,
    reason: reason.present ? reason.value : this.reason,
    category: category.present ? category.value : this.category,
    subCategory: subCategory.present ? subCategory.value : this.subCategory,
    logDate: logDate ?? this.logDate,
    userId: userId.present ? userId.value : this.userId,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  Mortality copyWithCompanion(MortalitiesCompanion data) {
    return Mortality(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      count: data.count.present ? data.count.value : this.count,
      reason: data.reason.present ? data.reason.value : this.reason,
      category: data.category.present ? data.category.value : this.category,
      subCategory: data.subCategory.present
          ? data.subCategory.value
          : this.subCategory,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mortality(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('count: $count, ')
          ..write('reason: $reason, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    batchId,
    count,
    reason,
    category,
    subCategory,
    logDate,
    userId,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mortality &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.batchId == this.batchId &&
          other.count == this.count &&
          other.reason == this.reason &&
          other.category == this.category &&
          other.subCategory == this.subCategory &&
          other.logDate == this.logDate &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class MortalitiesCompanion extends UpdateCompanion<Mortality> {
  final Value<int> id;
  final Value<int> farmId;
  final Value<int> batchId;
  final Value<int> count;
  final Value<String?> reason;
  final Value<String?> category;
  final Value<String?> subCategory;
  final Value<DateTime> logDate;
  final Value<String?> userId;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  const MortalitiesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.count = const Value.absent(),
    this.reason = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.logDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  MortalitiesCompanion.insert({
    this.id = const Value.absent(),
    required int farmId,
    required int batchId,
    required int count,
    this.reason = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    required DateTime logDate,
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
  }) : farmId = Value(farmId),
       batchId = Value(batchId),
       count = Value(count),
       logDate = Value(logDate);
  static Insertable<Mortality> custom({
    Expression<int>? id,
    Expression<int>? farmId,
    Expression<int>? batchId,
    Expression<int>? count,
    Expression<String>? reason,
    Expression<String>? category,
    Expression<String>? subCategory,
    Expression<DateTime>? logDate,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (batchId != null) 'batch_id': batchId,
      if (count != null) 'count': count,
      if (reason != null) 'reason': reason,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (logDate != null) 'log_date': logDate,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
    });
  }

  MortalitiesCompanion copyWith({
    Value<int>? id,
    Value<int>? farmId,
    Value<int>? batchId,
    Value<int>? count,
    Value<String?>? reason,
    Value<String?>? category,
    Value<String?>? subCategory,
    Value<DateTime>? logDate,
    Value<String?>? userId,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
  }) {
    return MortalitiesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      batchId: batchId ?? this.batchId,
      count: count ?? this.count,
      reason: reason ?? this.reason,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      logDate: logDate ?? this.logDate,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subCategory.present) {
      map['sub_category'] = Variable<String>(subCategory.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MortalitiesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('count: $count, ')
          ..write('reason: $reason, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $HousesTable extends Houses with TableInfo<$HousesTable, House> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HousesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentTemperatureMeta =
      const VerificationMeta('currentTemperature');
  @override
  late final GeneratedColumn<double> currentTemperature =
      GeneratedColumn<double>(
        'current_temperature',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currentHumidityMeta = const VerificationMeta(
    'currentHumidity',
  );
  @override
  late final GeneratedColumn<double> currentHumidity = GeneratedColumn<double>(
    'current_humidity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isIsolationMeta = const VerificationMeta(
    'isIsolation',
  );
  @override
  late final GeneratedColumn<bool> isIsolation = GeneratedColumn<bool>(
    'is_isolation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_isolation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    userId,
    name,
    capacity,
    currentTemperature,
    currentHumidity,
    isIsolation,
    createdAt,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'houses';
  @override
  VerificationContext validateIntegrity(
    Insertable<House> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    } else if (isInserting) {
      context.missing(_capacityMeta);
    }
    if (data.containsKey('current_temperature')) {
      context.handle(
        _currentTemperatureMeta,
        currentTemperature.isAcceptableOrUnknown(
          data['current_temperature']!,
          _currentTemperatureMeta,
        ),
      );
    }
    if (data.containsKey('current_humidity')) {
      context.handle(
        _currentHumidityMeta,
        currentHumidity.isAcceptableOrUnknown(
          data['current_humidity']!,
          _currentHumidityMeta,
        ),
      );
    }
    if (data.containsKey('is_isolation')) {
      context.handle(
        _isIsolationMeta,
        isIsolation.isAcceptableOrUnknown(
          data['is_isolation']!,
          _isIsolationMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  House map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return House(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      )!,
      currentTemperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_temperature'],
      ),
      currentHumidity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_humidity'],
      ),
      isIsolation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_isolation'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $HousesTable createAlias(String alias) {
    return $HousesTable(attachedDatabase, alias);
  }
}

class House extends DataClass implements Insertable<House> {
  final int id;
  final int farmId;
  final String? userId;
  final String name;
  final int capacity;
  final double? currentTemperature;
  final double? currentHumidity;
  final bool isIsolation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const House({
    required this.id,
    required this.farmId,
    this.userId,
    required this.name,
    required this.capacity,
    this.currentTemperature,
    this.currentHumidity,
    required this.isIsolation,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farm_id'] = Variable<int>(farmId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['name'] = Variable<String>(name);
    map['capacity'] = Variable<int>(capacity);
    if (!nullToAbsent || currentTemperature != null) {
      map['current_temperature'] = Variable<double>(currentTemperature);
    }
    if (!nullToAbsent || currentHumidity != null) {
      map['current_humidity'] = Variable<double>(currentHumidity);
    }
    map['is_isolation'] = Variable<bool>(isIsolation);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  HousesCompanion toCompanion(bool nullToAbsent) {
    return HousesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      name: Value(name),
      capacity: Value(capacity),
      currentTemperature: currentTemperature == null && nullToAbsent
          ? const Value.absent()
          : Value(currentTemperature),
      currentHumidity: currentHumidity == null && nullToAbsent
          ? const Value.absent()
          : Value(currentHumidity),
      isIsolation: Value(isIsolation),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory House.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return House(
      id: serializer.fromJson<int>(json['id']),
      farmId: serializer.fromJson<int>(json['farmId']),
      userId: serializer.fromJson<String?>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      capacity: serializer.fromJson<int>(json['capacity']),
      currentTemperature: serializer.fromJson<double?>(
        json['currentTemperature'],
      ),
      currentHumidity: serializer.fromJson<double?>(json['currentHumidity']),
      isIsolation: serializer.fromJson<bool>(json['isIsolation']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmId': serializer.toJson<int>(farmId),
      'userId': serializer.toJson<String?>(userId),
      'name': serializer.toJson<String>(name),
      'capacity': serializer.toJson<int>(capacity),
      'currentTemperature': serializer.toJson<double?>(currentTemperature),
      'currentHumidity': serializer.toJson<double?>(currentHumidity),
      'isIsolation': serializer.toJson<bool>(isIsolation),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  House copyWith({
    int? id,
    int? farmId,
    Value<String?> userId = const Value.absent(),
    String? name,
    int? capacity,
    Value<double?> currentTemperature = const Value.absent(),
    Value<double?> currentHumidity = const Value.absent(),
    bool? isIsolation,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) => House(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    userId: userId.present ? userId.value : this.userId,
    name: name ?? this.name,
    capacity: capacity ?? this.capacity,
    currentTemperature: currentTemperature.present
        ? currentTemperature.value
        : this.currentTemperature,
    currentHumidity: currentHumidity.present
        ? currentHumidity.value
        : this.currentHumidity,
    isIsolation: isIsolation ?? this.isIsolation,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  House copyWithCompanion(HousesCompanion data) {
    return House(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      currentTemperature: data.currentTemperature.present
          ? data.currentTemperature.value
          : this.currentTemperature,
      currentHumidity: data.currentHumidity.present
          ? data.currentHumidity.value
          : this.currentHumidity,
      isIsolation: data.isIsolation.present
          ? data.isIsolation.value
          : this.isIsolation,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('House(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('currentTemperature: $currentTemperature, ')
          ..write('currentHumidity: $currentHumidity, ')
          ..write('isIsolation: $isIsolation, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    userId,
    name,
    capacity,
    currentTemperature,
    currentHumidity,
    isIsolation,
    createdAt,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is House &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.capacity == this.capacity &&
          other.currentTemperature == this.currentTemperature &&
          other.currentHumidity == this.currentHumidity &&
          other.isIsolation == this.isIsolation &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class HousesCompanion extends UpdateCompanion<House> {
  final Value<int> id;
  final Value<int> farmId;
  final Value<String?> userId;
  final Value<String> name;
  final Value<int> capacity;
  final Value<double?> currentTemperature;
  final Value<double?> currentHumidity;
  final Value<bool> isIsolation;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  const HousesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.capacity = const Value.absent(),
    this.currentTemperature = const Value.absent(),
    this.currentHumidity = const Value.absent(),
    this.isIsolation = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  HousesCompanion.insert({
    this.id = const Value.absent(),
    required int farmId,
    this.userId = const Value.absent(),
    required String name,
    required int capacity,
    this.currentTemperature = const Value.absent(),
    this.currentHumidity = const Value.absent(),
    this.isIsolation = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
  }) : farmId = Value(farmId),
       name = Value(name),
       capacity = Value(capacity);
  static Insertable<House> custom({
    Expression<int>? id,
    Expression<int>? farmId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<int>? capacity,
    Expression<double>? currentTemperature,
    Expression<double>? currentHumidity,
    Expression<bool>? isIsolation,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (capacity != null) 'capacity': capacity,
      if (currentTemperature != null) 'current_temperature': currentTemperature,
      if (currentHumidity != null) 'current_humidity': currentHumidity,
      if (isIsolation != null) 'is_isolation': isIsolation,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
    });
  }

  HousesCompanion copyWith({
    Value<int>? id,
    Value<int>? farmId,
    Value<String?>? userId,
    Value<String>? name,
    Value<int>? capacity,
    Value<double?>? currentTemperature,
    Value<double?>? currentHumidity,
    Value<bool>? isIsolation,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
  }) {
    return HousesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      currentHumidity: currentHumidity ?? this.currentHumidity,
      isIsolation: isIsolation ?? this.isIsolation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (currentTemperature.present) {
      map['current_temperature'] = Variable<double>(currentTemperature.value);
    }
    if (currentHumidity.present) {
      map['current_humidity'] = Variable<double>(currentHumidity.value);
    }
    if (isIsolation.present) {
      map['is_isolation'] = Variable<bool>(isIsolation.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HousesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('currentTemperature: $currentTemperature, ')
          ..write('currentHumidity: $currentHumidity, ')
          ..write('isIsolation: $isIsolation, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceOwedMeta = const VerificationMeta(
    'balanceOwed',
  );
  @override
  late final GeneratedColumn<double> balanceOwed = GeneratedColumn<double>(
    'balance_owed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    name,
    phone,
    email,
    address,
    balanceOwed,
    createdAt,
    updatedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('balance_owed')) {
      context.handle(
        _balanceOwedMeta,
        balanceOwed.isAcceptableOrUnknown(
          data['balance_owed']!,
          _balanceOwedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      balanceOwed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance_owed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final int farmId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double balanceOwed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const Customer({
    required this.id,
    required this.farmId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.balanceOwed,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farm_id'] = Variable<int>(farmId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['balance_owed'] = Variable<double>(balanceOwed);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      farmId: Value(farmId),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      balanceOwed: Value(balanceOwed),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      farmId: serializer.fromJson<int>(json['farmId']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      balanceOwed: serializer.fromJson<double>(json['balanceOwed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmId': serializer.toJson<int>(farmId),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'balanceOwed': serializer.toJson<double>(balanceOwed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Customer copyWith({
    int? id,
    int? farmId,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    double? balanceOwed,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) => Customer(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    balanceOwed: balanceOwed ?? this.balanceOwed,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      balanceOwed: data.balanceOwed.present
          ? data.balanceOwed.value
          : this.balanceOwed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('balanceOwed: $balanceOwed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    name,
    phone,
    email,
    address,
    balanceOwed,
    createdAt,
    updatedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.balanceOwed == this.balanceOwed &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<int> farmId;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<double> balanceOwed;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.balanceOwed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    required int farmId,
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.balanceOwed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
  }) : farmId = Value(farmId),
       name = Value(name);
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<int>? farmId,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<double>? balanceOwed,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (balanceOwed != null) 'balance_owed': balanceOwed,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
    });
  }

  CustomersCompanion copyWith({
    Value<int>? id,
    Value<int>? farmId,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? address,
    Value<double>? balanceOwed,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      balanceOwed: balanceOwed ?? this.balanceOwed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (balanceOwed.present) {
      map['balance_owed'] = Variable<double>(balanceOwed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('balanceOwed: $balanceOwed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $FarmSettingsTable extends FarmSettings
    with TableInfo<$FarmSettingsTable, FarmSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GHS'),
  );
  static const VerificationMeta _eggRecordReminderTimeMeta =
      const VerificationMeta('eggRecordReminderTime');
  @override
  late final GeneratedColumn<String> eggRecordReminderTime =
      GeneratedColumn<String>(
        'egg_record_reminder_time',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _feedRecordReminderTimeMeta =
      const VerificationMeta('feedRecordReminderTime');
  @override
  late final GeneratedColumn<String> feedRecordReminderTime =
      GeneratedColumn<String>(
        'feed_record_reminder_time',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _growthTargetStandardMeta =
      const VerificationMeta('growthTargetStandard');
  @override
  late final GeneratedColumn<int> growthTargetStandard = GeneratedColumn<int>(
    'growth_target_standard',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eggsPerCrateMeta = const VerificationMeta(
    'eggsPerCrate',
  );
  @override
  late final GeneratedColumn<int> eggsPerCrate = GeneratedColumn<int>(
    'eggs_per_crate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    currency,
    eggRecordReminderTime,
    feedRecordReminderTime,
    growthTargetStandard,
    eggsPerCrate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<FarmSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('egg_record_reminder_time')) {
      context.handle(
        _eggRecordReminderTimeMeta,
        eggRecordReminderTime.isAcceptableOrUnknown(
          data['egg_record_reminder_time']!,
          _eggRecordReminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('feed_record_reminder_time')) {
      context.handle(
        _feedRecordReminderTimeMeta,
        feedRecordReminderTime.isAcceptableOrUnknown(
          data['feed_record_reminder_time']!,
          _feedRecordReminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('growth_target_standard')) {
      context.handle(
        _growthTargetStandardMeta,
        growthTargetStandard.isAcceptableOrUnknown(
          data['growth_target_standard']!,
          _growthTargetStandardMeta,
        ),
      );
    }
    if (data.containsKey('eggs_per_crate')) {
      context.handle(
        _eggsPerCrateMeta,
        eggsPerCrate.isAcceptableOrUnknown(
          data['eggs_per_crate']!,
          _eggsPerCrateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      eggRecordReminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}egg_record_reminder_time'],
      ),
      feedRecordReminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_record_reminder_time'],
      ),
      growthTargetStandard: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}growth_target_standard'],
      ),
      eggsPerCrate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eggs_per_crate'],
      )!,
    );
  }

  @override
  $FarmSettingsTable createAlias(String alias) {
    return $FarmSettingsTable(attachedDatabase, alias);
  }
}

class FarmSetting extends DataClass implements Insertable<FarmSetting> {
  final int id;
  final int farmId;
  final String currency;
  final String? eggRecordReminderTime;
  final String? feedRecordReminderTime;
  final int? growthTargetStandard;
  final int eggsPerCrate;
  const FarmSetting({
    required this.id,
    required this.farmId,
    required this.currency,
    this.eggRecordReminderTime,
    this.feedRecordReminderTime,
    this.growthTargetStandard,
    required this.eggsPerCrate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farm_id'] = Variable<int>(farmId);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || eggRecordReminderTime != null) {
      map['egg_record_reminder_time'] = Variable<String>(eggRecordReminderTime);
    }
    if (!nullToAbsent || feedRecordReminderTime != null) {
      map['feed_record_reminder_time'] = Variable<String>(
        feedRecordReminderTime,
      );
    }
    if (!nullToAbsent || growthTargetStandard != null) {
      map['growth_target_standard'] = Variable<int>(growthTargetStandard);
    }
    map['eggs_per_crate'] = Variable<int>(eggsPerCrate);
    return map;
  }

  FarmSettingsCompanion toCompanion(bool nullToAbsent) {
    return FarmSettingsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      currency: Value(currency),
      eggRecordReminderTime: eggRecordReminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(eggRecordReminderTime),
      feedRecordReminderTime: feedRecordReminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(feedRecordReminderTime),
      growthTargetStandard: growthTargetStandard == null && nullToAbsent
          ? const Value.absent()
          : Value(growthTargetStandard),
      eggsPerCrate: Value(eggsPerCrate),
    );
  }

  factory FarmSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmSetting(
      id: serializer.fromJson<int>(json['id']),
      farmId: serializer.fromJson<int>(json['farmId']),
      currency: serializer.fromJson<String>(json['currency']),
      eggRecordReminderTime: serializer.fromJson<String?>(
        json['eggRecordReminderTime'],
      ),
      feedRecordReminderTime: serializer.fromJson<String?>(
        json['feedRecordReminderTime'],
      ),
      growthTargetStandard: serializer.fromJson<int?>(
        json['growthTargetStandard'],
      ),
      eggsPerCrate: serializer.fromJson<int>(json['eggsPerCrate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmId': serializer.toJson<int>(farmId),
      'currency': serializer.toJson<String>(currency),
      'eggRecordReminderTime': serializer.toJson<String?>(
        eggRecordReminderTime,
      ),
      'feedRecordReminderTime': serializer.toJson<String?>(
        feedRecordReminderTime,
      ),
      'growthTargetStandard': serializer.toJson<int?>(growthTargetStandard),
      'eggsPerCrate': serializer.toJson<int>(eggsPerCrate),
    };
  }

  FarmSetting copyWith({
    int? id,
    int? farmId,
    String? currency,
    Value<String?> eggRecordReminderTime = const Value.absent(),
    Value<String?> feedRecordReminderTime = const Value.absent(),
    Value<int?> growthTargetStandard = const Value.absent(),
    int? eggsPerCrate,
  }) => FarmSetting(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    currency: currency ?? this.currency,
    eggRecordReminderTime: eggRecordReminderTime.present
        ? eggRecordReminderTime.value
        : this.eggRecordReminderTime,
    feedRecordReminderTime: feedRecordReminderTime.present
        ? feedRecordReminderTime.value
        : this.feedRecordReminderTime,
    growthTargetStandard: growthTargetStandard.present
        ? growthTargetStandard.value
        : this.growthTargetStandard,
    eggsPerCrate: eggsPerCrate ?? this.eggsPerCrate,
  );
  FarmSetting copyWithCompanion(FarmSettingsCompanion data) {
    return FarmSetting(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      currency: data.currency.present ? data.currency.value : this.currency,
      eggRecordReminderTime: data.eggRecordReminderTime.present
          ? data.eggRecordReminderTime.value
          : this.eggRecordReminderTime,
      feedRecordReminderTime: data.feedRecordReminderTime.present
          ? data.feedRecordReminderTime.value
          : this.feedRecordReminderTime,
      growthTargetStandard: data.growthTargetStandard.present
          ? data.growthTargetStandard.value
          : this.growthTargetStandard,
      eggsPerCrate: data.eggsPerCrate.present
          ? data.eggsPerCrate.value
          : this.eggsPerCrate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmSetting(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('currency: $currency, ')
          ..write('eggRecordReminderTime: $eggRecordReminderTime, ')
          ..write('feedRecordReminderTime: $feedRecordReminderTime, ')
          ..write('growthTargetStandard: $growthTargetStandard, ')
          ..write('eggsPerCrate: $eggsPerCrate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    currency,
    eggRecordReminderTime,
    feedRecordReminderTime,
    growthTargetStandard,
    eggsPerCrate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmSetting &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.currency == this.currency &&
          other.eggRecordReminderTime == this.eggRecordReminderTime &&
          other.feedRecordReminderTime == this.feedRecordReminderTime &&
          other.growthTargetStandard == this.growthTargetStandard &&
          other.eggsPerCrate == this.eggsPerCrate);
}

class FarmSettingsCompanion extends UpdateCompanion<FarmSetting> {
  final Value<int> id;
  final Value<int> farmId;
  final Value<String> currency;
  final Value<String?> eggRecordReminderTime;
  final Value<String?> feedRecordReminderTime;
  final Value<int?> growthTargetStandard;
  final Value<int> eggsPerCrate;
  const FarmSettingsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.currency = const Value.absent(),
    this.eggRecordReminderTime = const Value.absent(),
    this.feedRecordReminderTime = const Value.absent(),
    this.growthTargetStandard = const Value.absent(),
    this.eggsPerCrate = const Value.absent(),
  });
  FarmSettingsCompanion.insert({
    this.id = const Value.absent(),
    required int farmId,
    this.currency = const Value.absent(),
    this.eggRecordReminderTime = const Value.absent(),
    this.feedRecordReminderTime = const Value.absent(),
    this.growthTargetStandard = const Value.absent(),
    this.eggsPerCrate = const Value.absent(),
  }) : farmId = Value(farmId);
  static Insertable<FarmSetting> custom({
    Expression<int>? id,
    Expression<int>? farmId,
    Expression<String>? currency,
    Expression<String>? eggRecordReminderTime,
    Expression<String>? feedRecordReminderTime,
    Expression<int>? growthTargetStandard,
    Expression<int>? eggsPerCrate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (currency != null) 'currency': currency,
      if (eggRecordReminderTime != null)
        'egg_record_reminder_time': eggRecordReminderTime,
      if (feedRecordReminderTime != null)
        'feed_record_reminder_time': feedRecordReminderTime,
      if (growthTargetStandard != null)
        'growth_target_standard': growthTargetStandard,
      if (eggsPerCrate != null) 'eggs_per_crate': eggsPerCrate,
    });
  }

  FarmSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? farmId,
    Value<String>? currency,
    Value<String?>? eggRecordReminderTime,
    Value<String?>? feedRecordReminderTime,
    Value<int?>? growthTargetStandard,
    Value<int>? eggsPerCrate,
  }) {
    return FarmSettingsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      currency: currency ?? this.currency,
      eggRecordReminderTime:
          eggRecordReminderTime ?? this.eggRecordReminderTime,
      feedRecordReminderTime:
          feedRecordReminderTime ?? this.feedRecordReminderTime,
      growthTargetStandard: growthTargetStandard ?? this.growthTargetStandard,
      eggsPerCrate: eggsPerCrate ?? this.eggsPerCrate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (eggRecordReminderTime.present) {
      map['egg_record_reminder_time'] = Variable<String>(
        eggRecordReminderTime.value,
      );
    }
    if (feedRecordReminderTime.present) {
      map['feed_record_reminder_time'] = Variable<String>(
        feedRecordReminderTime.value,
      );
    }
    if (growthTargetStandard.present) {
      map['growth_target_standard'] = Variable<int>(growthTargetStandard.value);
    }
    if (eggsPerCrate.present) {
      map['eggs_per_crate'] = Variable<int>(eggsPerCrate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmSettingsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('currency: $currency, ')
          ..write('eggRecordReminderTime: $eggRecordReminderTime, ')
          ..write('feedRecordReminderTime: $feedRecordReminderTime, ')
          ..write('growthTargetStandard: $growthTargetStandard, ')
          ..write('eggsPerCrate: $eggsPerCrate')
          ..write(')'))
        .toString();
  }
}

class $WeightRecordsTable extends WeightRecords
    with TableInfo<$WeightRecordsTable, WeightRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageWeightMeta = const VerificationMeta(
    'averageWeight',
  );
  @override
  late final GeneratedColumn<double> averageWeight = GeneratedColumn<double>(
    'average_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    batchId,
    averageWeight,
    logDate,
    userId,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('average_weight')) {
      context.handle(
        _averageWeightMeta,
        averageWeight.isAcceptableOrUnknown(
          data['average_weight']!,
          _averageWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageWeightMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
      averageWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_weight'],
      )!,
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}log_date'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $WeightRecordsTable createAlias(String alias) {
    return $WeightRecordsTable(attachedDatabase, alias);
  }
}

class WeightRecord extends DataClass implements Insertable<WeightRecord> {
  final int id;
  final int farmId;
  final int batchId;
  final double averageWeight;
  final DateTime logDate;
  final String? userId;
  final DateTime createdAt;
  final bool synced;
  const WeightRecord({
    required this.id,
    required this.farmId,
    required this.batchId,
    required this.averageWeight,
    required this.logDate,
    this.userId,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farm_id'] = Variable<int>(farmId);
    map['batch_id'] = Variable<int>(batchId);
    map['average_weight'] = Variable<double>(averageWeight);
    map['log_date'] = Variable<DateTime>(logDate);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  WeightRecordsCompanion toCompanion(bool nullToAbsent) {
    return WeightRecordsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      batchId: Value(batchId),
      averageWeight: Value(averageWeight),
      logDate: Value(logDate),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory WeightRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightRecord(
      id: serializer.fromJson<int>(json['id']),
      farmId: serializer.fromJson<int>(json['farmId']),
      batchId: serializer.fromJson<int>(json['batchId']),
      averageWeight: serializer.fromJson<double>(json['averageWeight']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      userId: serializer.fromJson<String?>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmId': serializer.toJson<int>(farmId),
      'batchId': serializer.toJson<int>(batchId),
      'averageWeight': serializer.toJson<double>(averageWeight),
      'logDate': serializer.toJson<DateTime>(logDate),
      'userId': serializer.toJson<String?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  WeightRecord copyWith({
    int? id,
    int? farmId,
    int? batchId,
    double? averageWeight,
    DateTime? logDate,
    Value<String?> userId = const Value.absent(),
    DateTime? createdAt,
    bool? synced,
  }) => WeightRecord(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    batchId: batchId ?? this.batchId,
    averageWeight: averageWeight ?? this.averageWeight,
    logDate: logDate ?? this.logDate,
    userId: userId.present ? userId.value : this.userId,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  WeightRecord copyWithCompanion(WeightRecordsCompanion data) {
    return WeightRecord(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      averageWeight: data.averageWeight.present
          ? data.averageWeight.value
          : this.averageWeight,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightRecord(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('averageWeight: $averageWeight, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    batchId,
    averageWeight,
    logDate,
    userId,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightRecord &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.batchId == this.batchId &&
          other.averageWeight == this.averageWeight &&
          other.logDate == this.logDate &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class WeightRecordsCompanion extends UpdateCompanion<WeightRecord> {
  final Value<int> id;
  final Value<int> farmId;
  final Value<int> batchId;
  final Value<double> averageWeight;
  final Value<DateTime> logDate;
  final Value<String?> userId;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  const WeightRecordsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.averageWeight = const Value.absent(),
    this.logDate = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  WeightRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int farmId,
    required int batchId,
    required double averageWeight,
    required DateTime logDate,
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
  }) : farmId = Value(farmId),
       batchId = Value(batchId),
       averageWeight = Value(averageWeight),
       logDate = Value(logDate);
  static Insertable<WeightRecord> custom({
    Expression<int>? id,
    Expression<int>? farmId,
    Expression<int>? batchId,
    Expression<double>? averageWeight,
    Expression<DateTime>? logDate,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (batchId != null) 'batch_id': batchId,
      if (averageWeight != null) 'average_weight': averageWeight,
      if (logDate != null) 'log_date': logDate,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
    });
  }

  WeightRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? farmId,
    Value<int>? batchId,
    Value<double>? averageWeight,
    Value<DateTime>? logDate,
    Value<String?>? userId,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
  }) {
    return WeightRecordsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      batchId: batchId ?? this.batchId,
      averageWeight: averageWeight ?? this.averageWeight,
      logDate: logDate ?? this.logDate,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (averageWeight.present) {
      map['average_weight'] = Variable<double>(averageWeight.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightRecordsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('batchId: $batchId, ')
          ..write('averageWeight: $averageWeight, ')
          ..write('logDate: $logDate, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $DeviceRegistrationsTable extends DeviceRegistrations
    with TableInfo<$DeviceRegistrationsTable, DeviceRegistration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceRegistrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdentifierMeta = const VerificationMeta(
    'deviceIdentifier',
  );
  @override
  late final GeneratedColumn<String> deviceIdentifier = GeneratedColumn<String>(
    'device_identifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registeredAtMeta = const VerificationMeta(
    'registeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> registeredAt = GeneratedColumn<DateTime>(
    'registered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    userId,
    deviceIdentifier,
    deviceName,
    registeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_registrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceRegistration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('device_identifier')) {
      context.handle(
        _deviceIdentifierMeta,
        deviceIdentifier.isAcceptableOrUnknown(
          data['device_identifier']!,
          _deviceIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceIdentifierMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    }
    if (data.containsKey('registered_at')) {
      context.handle(
        _registeredAtMeta,
        registeredAt.isAcceptableOrUnknown(
          data['registered_at']!,
          _registeredAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceRegistration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceRegistration(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      deviceIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_identifier'],
      )!,
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      ),
      registeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}registered_at'],
      )!,
    );
  }

  @override
  $DeviceRegistrationsTable createAlias(String alias) {
    return $DeviceRegistrationsTable(attachedDatabase, alias);
  }
}

class DeviceRegistration extends DataClass
    implements Insertable<DeviceRegistration> {
  final String id;
  final int farmId;
  final String userId;
  final String deviceIdentifier;
  final String? deviceName;
  final DateTime registeredAt;
  const DeviceRegistration({
    required this.id,
    required this.farmId,
    required this.userId,
    required this.deviceIdentifier,
    this.deviceName,
    required this.registeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<int>(farmId);
    map['user_id'] = Variable<String>(userId);
    map['device_identifier'] = Variable<String>(deviceIdentifier);
    if (!nullToAbsent || deviceName != null) {
      map['device_name'] = Variable<String>(deviceName);
    }
    map['registered_at'] = Variable<DateTime>(registeredAt);
    return map;
  }

  DeviceRegistrationsCompanion toCompanion(bool nullToAbsent) {
    return DeviceRegistrationsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      userId: Value(userId),
      deviceIdentifier: Value(deviceIdentifier),
      deviceName: deviceName == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceName),
      registeredAt: Value(registeredAt),
    );
  }

  factory DeviceRegistration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceRegistration(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<int>(json['farmId']),
      userId: serializer.fromJson<String>(json['userId']),
      deviceIdentifier: serializer.fromJson<String>(json['deviceIdentifier']),
      deviceName: serializer.fromJson<String?>(json['deviceName']),
      registeredAt: serializer.fromJson<DateTime>(json['registeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<int>(farmId),
      'userId': serializer.toJson<String>(userId),
      'deviceIdentifier': serializer.toJson<String>(deviceIdentifier),
      'deviceName': serializer.toJson<String?>(deviceName),
      'registeredAt': serializer.toJson<DateTime>(registeredAt),
    };
  }

  DeviceRegistration copyWith({
    String? id,
    int? farmId,
    String? userId,
    String? deviceIdentifier,
    Value<String?> deviceName = const Value.absent(),
    DateTime? registeredAt,
  }) => DeviceRegistration(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    userId: userId ?? this.userId,
    deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
    deviceName: deviceName.present ? deviceName.value : this.deviceName,
    registeredAt: registeredAt ?? this.registeredAt,
  );
  DeviceRegistration copyWithCompanion(DeviceRegistrationsCompanion data) {
    return DeviceRegistration(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceIdentifier: data.deviceIdentifier.present
          ? data.deviceIdentifier.value
          : this.deviceIdentifier,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      registeredAt: data.registeredAt.present
          ? data.registeredAt.value
          : this.registeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceRegistration(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('deviceIdentifier: $deviceIdentifier, ')
          ..write('deviceName: $deviceName, ')
          ..write('registeredAt: $registeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    userId,
    deviceIdentifier,
    deviceName,
    registeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceRegistration &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.userId == this.userId &&
          other.deviceIdentifier == this.deviceIdentifier &&
          other.deviceName == this.deviceName &&
          other.registeredAt == this.registeredAt);
}

class DeviceRegistrationsCompanion extends UpdateCompanion<DeviceRegistration> {
  final Value<String> id;
  final Value<int> farmId;
  final Value<String> userId;
  final Value<String> deviceIdentifier;
  final Value<String?> deviceName;
  final Value<DateTime> registeredAt;
  final Value<int> rowid;
  const DeviceRegistrationsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceIdentifier = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.registeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceRegistrationsCompanion.insert({
    required String id,
    required int farmId,
    required String userId,
    required String deviceIdentifier,
    this.deviceName = const Value.absent(),
    this.registeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       userId = Value(userId),
       deviceIdentifier = Value(deviceIdentifier);
  static Insertable<DeviceRegistration> custom({
    Expression<String>? id,
    Expression<int>? farmId,
    Expression<String>? userId,
    Expression<String>? deviceIdentifier,
    Expression<String>? deviceName,
    Expression<DateTime>? registeredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (deviceIdentifier != null) 'device_identifier': deviceIdentifier,
      if (deviceName != null) 'device_name': deviceName,
      if (registeredAt != null) 'registered_at': registeredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceRegistrationsCompanion copyWith({
    Value<String>? id,
    Value<int>? farmId,
    Value<String>? userId,
    Value<String>? deviceIdentifier,
    Value<String?>? deviceName,
    Value<DateTime>? registeredAt,
    Value<int>? rowid,
  }) {
    return DeviceRegistrationsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      userId: userId ?? this.userId,
      deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
      deviceName: deviceName ?? this.deviceName,
      registeredAt: registeredAt ?? this.registeredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceIdentifier.present) {
      map['device_identifier'] = Variable<String>(deviceIdentifier.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (registeredAt.present) {
      map['registered_at'] = Variable<DateTime>(registeredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceRegistrationsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('deviceIdentifier: $deviceIdentifier, ')
          ..write('deviceName: $deviceName, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmMembersTable extends FarmMembers
    with TableInfo<$FarmMembersTable, FarmMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('WORKER'),
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, farmId, userId, role, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<FarmMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
    );
  }

  @override
  $FarmMembersTable createAlias(String alias) {
    return $FarmMembersTable(attachedDatabase, alias);
  }
}

class FarmMember extends DataClass implements Insertable<FarmMember> {
  final int id;
  final int farmId;
  final String userId;
  final String role;
  final DateTime joinedAt;
  const FarmMember({
    required this.id,
    required this.farmId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farm_id'] = Variable<int>(farmId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    return map;
  }

  FarmMembersCompanion toCompanion(bool nullToAbsent) {
    return FarmMembersCompanion(
      id: Value(id),
      farmId: Value(farmId),
      userId: Value(userId),
      role: Value(role),
      joinedAt: Value(joinedAt),
    );
  }

  factory FarmMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmMember(
      id: serializer.fromJson<int>(json['id']),
      farmId: serializer.fromJson<int>(json['farmId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmId': serializer.toJson<int>(farmId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
    };
  }

  FarmMember copyWith({
    int? id,
    int? farmId,
    String? userId,
    String? role,
    DateTime? joinedAt,
  }) => FarmMember(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    joinedAt: joinedAt ?? this.joinedAt,
  );
  FarmMember copyWithCompanion(FarmMembersCompanion data) {
    return FarmMember(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmMember(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, farmId, userId, role, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmMember &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.joinedAt == this.joinedAt);
}

class FarmMembersCompanion extends UpdateCompanion<FarmMember> {
  final Value<int> id;
  final Value<int> farmId;
  final Value<String> userId;
  final Value<String> role;
  final Value<DateTime> joinedAt;
  const FarmMembersCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
  });
  FarmMembersCompanion.insert({
    this.id = const Value.absent(),
    required int farmId,
    required String userId,
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
  }) : farmId = Value(farmId),
       userId = Value(userId);
  static Insertable<FarmMember> custom({
    Expression<int>? id,
    Expression<int>? farmId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<DateTime>? joinedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (joinedAt != null) 'joined_at': joinedAt,
    });
  }

  FarmMembersCompanion copyWith({
    Value<int>? id,
    Value<int>? farmId,
    Value<String>? userId,
    Value<String>? role,
    Value<DateTime>? joinedAt,
  }) {
    return FarmMembersCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmMembersCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }
}

class $FeedTypesTable extends FeedTypes
    with TableInfo<$FeedTypesTable, FeedType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, farmId, name, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $FeedTypesTable createAlias(String alias) {
    return $FeedTypesTable(attachedDatabase, alias);
  }
}

class FeedType extends DataClass implements Insertable<FeedType> {
  final int id;
  final int farmId;
  final String name;
  final String? description;
  const FeedType({
    required this.id,
    required this.farmId,
    required this.name,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farm_id'] = Variable<int>(farmId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  FeedTypesCompanion toCompanion(bool nullToAbsent) {
    return FeedTypesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory FeedType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedType(
      id: serializer.fromJson<int>(json['id']),
      farmId: serializer.fromJson<int>(json['farmId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmId': serializer.toJson<int>(farmId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
    };
  }

  FeedType copyWith({
    int? id,
    int? farmId,
    String? name,
    Value<String?> description = const Value.absent(),
  }) => FeedType(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
  );
  FeedType copyWithCompanion(FeedTypesCompanion data) {
    return FeedType(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedType(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, farmId, name, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedType &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.name == this.name &&
          other.description == this.description);
}

class FeedTypesCompanion extends UpdateCompanion<FeedType> {
  final Value<int> id;
  final Value<int> farmId;
  final Value<String> name;
  final Value<String?> description;
  const FeedTypesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
  });
  FeedTypesCompanion.insert({
    this.id = const Value.absent(),
    required int farmId,
    required String name,
    this.description = const Value.absent(),
  }) : farmId = Value(farmId),
       name = Value(name);
  static Insertable<FeedType> custom({
    Expression<int>? id,
    Expression<int>? farmId,
    Expression<String>? name,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
    });
  }

  FeedTypesCompanion copyWith({
    Value<int>? id,
    Value<int>? farmId,
    Value<String>? name,
    Value<String?>? description,
  }) {
    return FeedTypesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedTypesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $FeedFormulationsTable extends FeedFormulations
    with TableInfo<$FeedFormulationsTable, FeedFormulation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedFormulationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientsJsonMeta = const VerificationMeta(
    'ingredientsJson',
  );
  @override
  late final GeneratedColumn<String> ingredientsJson = GeneratedColumn<String>(
    'ingredients_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, farmId, name, ingredientsJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_formulations';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedFormulation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('ingredients_json')) {
      context.handle(
        _ingredientsJsonMeta,
        ingredientsJson.isAcceptableOrUnknown(
          data['ingredients_json']!,
          _ingredientsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedFormulation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedFormulation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      ingredientsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredients_json'],
      ),
    );
  }

  @override
  $FeedFormulationsTable createAlias(String alias) {
    return $FeedFormulationsTable(attachedDatabase, alias);
  }
}

class FeedFormulation extends DataClass implements Insertable<FeedFormulation> {
  final int id;
  final int farmId;
  final String name;
  final String? ingredientsJson;
  const FeedFormulation({
    required this.id,
    required this.farmId,
    required this.name,
    this.ingredientsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['farm_id'] = Variable<int>(farmId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || ingredientsJson != null) {
      map['ingredients_json'] = Variable<String>(ingredientsJson);
    }
    return map;
  }

  FeedFormulationsCompanion toCompanion(bool nullToAbsent) {
    return FeedFormulationsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      name: Value(name),
      ingredientsJson: ingredientsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientsJson),
    );
  }

  factory FeedFormulation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedFormulation(
      id: serializer.fromJson<int>(json['id']),
      farmId: serializer.fromJson<int>(json['farmId']),
      name: serializer.fromJson<String>(json['name']),
      ingredientsJson: serializer.fromJson<String?>(json['ingredientsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'farmId': serializer.toJson<int>(farmId),
      'name': serializer.toJson<String>(name),
      'ingredientsJson': serializer.toJson<String?>(ingredientsJson),
    };
  }

  FeedFormulation copyWith({
    int? id,
    int? farmId,
    String? name,
    Value<String?> ingredientsJson = const Value.absent(),
  }) => FeedFormulation(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    name: name ?? this.name,
    ingredientsJson: ingredientsJson.present
        ? ingredientsJson.value
        : this.ingredientsJson,
  );
  FeedFormulation copyWithCompanion(FeedFormulationsCompanion data) {
    return FeedFormulation(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      name: data.name.present ? data.name.value : this.name,
      ingredientsJson: data.ingredientsJson.present
          ? data.ingredientsJson.value
          : this.ingredientsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedFormulation(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('ingredientsJson: $ingredientsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, farmId, name, ingredientsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedFormulation &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.name == this.name &&
          other.ingredientsJson == this.ingredientsJson);
}

class FeedFormulationsCompanion extends UpdateCompanion<FeedFormulation> {
  final Value<int> id;
  final Value<int> farmId;
  final Value<String> name;
  final Value<String?> ingredientsJson;
  const FeedFormulationsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.name = const Value.absent(),
    this.ingredientsJson = const Value.absent(),
  });
  FeedFormulationsCompanion.insert({
    this.id = const Value.absent(),
    required int farmId,
    required String name,
    this.ingredientsJson = const Value.absent(),
  }) : farmId = Value(farmId),
       name = Value(name);
  static Insertable<FeedFormulation> custom({
    Expression<int>? id,
    Expression<int>? farmId,
    Expression<String>? name,
    Expression<String>? ingredientsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (name != null) 'name': name,
      if (ingredientsJson != null) 'ingredients_json': ingredientsJson,
    });
  }

  FeedFormulationsCompanion copyWith({
    Value<int>? id,
    Value<int>? farmId,
    Value<String>? name,
    Value<String?>? ingredientsJson,
  }) {
    return FeedFormulationsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      ingredientsJson: ingredientsJson ?? this.ingredientsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ingredientsJson.present) {
      map['ingredients_json'] = Variable<String>(ingredientsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedFormulationsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('ingredientsJson: $ingredientsJson')
          ..write(')'))
        .toString();
  }
}

class $VaccinationSchedulesTable extends VaccinationSchedules
    with TableInfo<$VaccinationSchedulesTable, VaccinationSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaccinationSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vaccineNameMeta = const VerificationMeta(
    'vaccineName',
  );
  @override
  late final GeneratedColumn<String> vaccineName = GeneratedColumn<String>(
    'vaccine_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    vaccineName,
    scheduledDate,
    status,
    notes,
    farmId,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaccination_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaccinationSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('vaccine_name')) {
      context.handle(
        _vaccineNameMeta,
        vaccineName.isAcceptableOrUnknown(
          data['vaccine_name']!,
          _vaccineNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vaccineNameMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaccinationSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaccinationSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
      vaccineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vaccine_name'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $VaccinationSchedulesTable createAlias(String alias) {
    return $VaccinationSchedulesTable(attachedDatabase, alias);
  }
}

class VaccinationSchedule extends DataClass
    implements Insertable<VaccinationSchedule> {
  final int id;
  final int batchId;
  final String vaccineName;
  final DateTime scheduledDate;
  final String status;
  final String? notes;
  final int farmId;
  final bool synced;
  const VaccinationSchedule({
    required this.id,
    required this.batchId,
    required this.vaccineName,
    required this.scheduledDate,
    required this.status,
    this.notes,
    required this.farmId,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['batch_id'] = Variable<int>(batchId);
    map['vaccine_name'] = Variable<String>(vaccineName);
    map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['farm_id'] = Variable<int>(farmId);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  VaccinationSchedulesCompanion toCompanion(bool nullToAbsent) {
    return VaccinationSchedulesCompanion(
      id: Value(id),
      batchId: Value(batchId),
      vaccineName: Value(vaccineName),
      scheduledDate: Value(scheduledDate),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      farmId: Value(farmId),
      synced: Value(synced),
    );
  }

  factory VaccinationSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaccinationSchedule(
      id: serializer.fromJson<int>(json['id']),
      batchId: serializer.fromJson<int>(json['batchId']),
      vaccineName: serializer.fromJson<String>(json['vaccineName']),
      scheduledDate: serializer.fromJson<DateTime>(json['scheduledDate']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      farmId: serializer.fromJson<int>(json['farmId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'batchId': serializer.toJson<int>(batchId),
      'vaccineName': serializer.toJson<String>(vaccineName),
      'scheduledDate': serializer.toJson<DateTime>(scheduledDate),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'farmId': serializer.toJson<int>(farmId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  VaccinationSchedule copyWith({
    int? id,
    int? batchId,
    String? vaccineName,
    DateTime? scheduledDate,
    String? status,
    Value<String?> notes = const Value.absent(),
    int? farmId,
    bool? synced,
  }) => VaccinationSchedule(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    vaccineName: vaccineName ?? this.vaccineName,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    farmId: farmId ?? this.farmId,
    synced: synced ?? this.synced,
  );
  VaccinationSchedule copyWithCompanion(VaccinationSchedulesCompanion data) {
    return VaccinationSchedule(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      vaccineName: data.vaccineName.present
          ? data.vaccineName.value
          : this.vaccineName,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationSchedule(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('farmId: $farmId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchId,
    vaccineName,
    scheduledDate,
    status,
    notes,
    farmId,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaccinationSchedule &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.vaccineName == this.vaccineName &&
          other.scheduledDate == this.scheduledDate &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.farmId == this.farmId &&
          other.synced == this.synced);
}

class VaccinationSchedulesCompanion
    extends UpdateCompanion<VaccinationSchedule> {
  final Value<int> id;
  final Value<int> batchId;
  final Value<String> vaccineName;
  final Value<DateTime> scheduledDate;
  final Value<String> status;
  final Value<String?> notes;
  final Value<int> farmId;
  final Value<bool> synced;
  const VaccinationSchedulesCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.vaccineName = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.farmId = const Value.absent(),
    this.synced = const Value.absent(),
  });
  VaccinationSchedulesCompanion.insert({
    this.id = const Value.absent(),
    required int batchId,
    required String vaccineName,
    required DateTime scheduledDate,
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required int farmId,
    this.synced = const Value.absent(),
  }) : batchId = Value(batchId),
       vaccineName = Value(vaccineName),
       scheduledDate = Value(scheduledDate),
       farmId = Value(farmId);
  static Insertable<VaccinationSchedule> custom({
    Expression<int>? id,
    Expression<int>? batchId,
    Expression<String>? vaccineName,
    Expression<DateTime>? scheduledDate,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<int>? farmId,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (vaccineName != null) 'vaccine_name': vaccineName,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (farmId != null) 'farm_id': farmId,
      if (synced != null) 'synced': synced,
    });
  }

  VaccinationSchedulesCompanion copyWith({
    Value<int>? id,
    Value<int>? batchId,
    Value<String>? vaccineName,
    Value<DateTime>? scheduledDate,
    Value<String>? status,
    Value<String?>? notes,
    Value<int>? farmId,
    Value<bool>? synced,
  }) {
    return VaccinationSchedulesCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      vaccineName: vaccineName ?? this.vaccineName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      farmId: farmId ?? this.farmId,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (vaccineName.present) {
      map['vaccine_name'] = Variable<String>(vaccineName.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('farmId: $farmId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $MedicationSchedulesTable extends MedicationSchedules
    with TableInfo<$MedicationSchedulesTable, MedicationSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicationNameMeta = const VerificationMeta(
    'medicationName',
  );
  @override
  late final GeneratedColumn<String> medicationName = GeneratedColumn<String>(
    'medication_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<int> farmId = GeneratedColumn<int>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    medicationName,
    scheduledDate,
    status,
    notes,
    farmId,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('medication_name')) {
      context.handle(
        _medicationNameMeta,
        medicationName.isAcceptableOrUnknown(
          data['medication_name']!,
          _medicationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationNameMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
      medicationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_name'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farm_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $MedicationSchedulesTable createAlias(String alias) {
    return $MedicationSchedulesTable(attachedDatabase, alias);
  }
}

class MedicationSchedule extends DataClass
    implements Insertable<MedicationSchedule> {
  final int id;
  final int batchId;
  final String medicationName;
  final DateTime scheduledDate;
  final String status;
  final String? notes;
  final int farmId;
  final bool synced;
  const MedicationSchedule({
    required this.id,
    required this.batchId,
    required this.medicationName,
    required this.scheduledDate,
    required this.status,
    this.notes,
    required this.farmId,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['batch_id'] = Variable<int>(batchId);
    map['medication_name'] = Variable<String>(medicationName);
    map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['farm_id'] = Variable<int>(farmId);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  MedicationSchedulesCompanion toCompanion(bool nullToAbsent) {
    return MedicationSchedulesCompanion(
      id: Value(id),
      batchId: Value(batchId),
      medicationName: Value(medicationName),
      scheduledDate: Value(scheduledDate),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      farmId: Value(farmId),
      synced: Value(synced),
    );
  }

  factory MedicationSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationSchedule(
      id: serializer.fromJson<int>(json['id']),
      batchId: serializer.fromJson<int>(json['batchId']),
      medicationName: serializer.fromJson<String>(json['medicationName']),
      scheduledDate: serializer.fromJson<DateTime>(json['scheduledDate']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      farmId: serializer.fromJson<int>(json['farmId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'batchId': serializer.toJson<int>(batchId),
      'medicationName': serializer.toJson<String>(medicationName),
      'scheduledDate': serializer.toJson<DateTime>(scheduledDate),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'farmId': serializer.toJson<int>(farmId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  MedicationSchedule copyWith({
    int? id,
    int? batchId,
    String? medicationName,
    DateTime? scheduledDate,
    String? status,
    Value<String?> notes = const Value.absent(),
    int? farmId,
    bool? synced,
  }) => MedicationSchedule(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    medicationName: medicationName ?? this.medicationName,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    farmId: farmId ?? this.farmId,
    synced: synced ?? this.synced,
  );
  MedicationSchedule copyWithCompanion(MedicationSchedulesCompanion data) {
    return MedicationSchedule(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      medicationName: data.medicationName.present
          ? data.medicationName.value
          : this.medicationName,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationSchedule(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('medicationName: $medicationName, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('farmId: $farmId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchId,
    medicationName,
    scheduledDate,
    status,
    notes,
    farmId,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationSchedule &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.medicationName == this.medicationName &&
          other.scheduledDate == this.scheduledDate &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.farmId == this.farmId &&
          other.synced == this.synced);
}

class MedicationSchedulesCompanion extends UpdateCompanion<MedicationSchedule> {
  final Value<int> id;
  final Value<int> batchId;
  final Value<String> medicationName;
  final Value<DateTime> scheduledDate;
  final Value<String> status;
  final Value<String?> notes;
  final Value<int> farmId;
  final Value<bool> synced;
  const MedicationSchedulesCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.medicationName = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.farmId = const Value.absent(),
    this.synced = const Value.absent(),
  });
  MedicationSchedulesCompanion.insert({
    this.id = const Value.absent(),
    required int batchId,
    required String medicationName,
    required DateTime scheduledDate,
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required int farmId,
    this.synced = const Value.absent(),
  }) : batchId = Value(batchId),
       medicationName = Value(medicationName),
       scheduledDate = Value(scheduledDate),
       farmId = Value(farmId);
  static Insertable<MedicationSchedule> custom({
    Expression<int>? id,
    Expression<int>? batchId,
    Expression<String>? medicationName,
    Expression<DateTime>? scheduledDate,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<int>? farmId,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (medicationName != null) 'medication_name': medicationName,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (farmId != null) 'farm_id': farmId,
      if (synced != null) 'synced': synced,
    });
  }

  MedicationSchedulesCompanion copyWith({
    Value<int>? id,
    Value<int>? batchId,
    Value<String>? medicationName,
    Value<DateTime>? scheduledDate,
    Value<String>? status,
    Value<String?>? notes,
    Value<int>? farmId,
    Value<bool>? synced,
  }) {
    return MedicationSchedulesCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      medicationName: medicationName ?? this.medicationName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      farmId: farmId ?? this.farmId,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (medicationName.present) {
      map['medication_name'] = Variable<String>(medicationName.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<int>(farmId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('medicationName: $medicationName, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('farmId: $farmId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $FarmsTable farms = $FarmsTable(this);
  late final $BatchesTable batches = $BatchesTable(this);
  late final $InventoryTable inventory = $InventoryTable(this);
  late final $FeedingLogsTable feedingLogs = $FeedingLogsTable(this);
  late final $EggProductionsTable eggProductions = $EggProductionsTable(this);
  late final $MortalitiesTable mortalities = $MortalitiesTable(this);
  late final $HousesTable houses = $HousesTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $FarmSettingsTable farmSettings = $FarmSettingsTable(this);
  late final $WeightRecordsTable weightRecords = $WeightRecordsTable(this);
  late final $DeviceRegistrationsTable deviceRegistrations =
      $DeviceRegistrationsTable(this);
  late final $FarmMembersTable farmMembers = $FarmMembersTable(this);
  late final $FeedTypesTable feedTypes = $FeedTypesTable(this);
  late final $FeedFormulationsTable feedFormulations = $FeedFormulationsTable(
    this,
  );
  late final $VaccinationSchedulesTable vaccinationSchedules =
      $VaccinationSchedulesTable(this);
  late final $MedicationSchedulesTable medicationSchedules =
      $MedicationSchedulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    farms,
    batches,
    inventory,
    feedingLogs,
    eggProductions,
    mortalities,
    houses,
    customers,
    farmSettings,
    weightRecords,
    deviceRegistrations,
    farmMembers,
    feedTypes,
    feedFormulations,
    vaccinationSchedules,
    medicationSchedules,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      Value<String?> firstname,
      Value<String?> surname,
      Value<String?> middleName,
      Value<String?> name,
      Value<String?> email,
      Value<String?> image,
      Value<String?> password,
      Value<String?> phoneNumber,
      Value<bool> mustChangePassword,
      Value<String> role,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String?> firstname,
      Value<String?> surname,
      Value<String?> middleName,
      Value<String?> name,
      Value<String?> email,
      Value<String?> image,
      Value<String?> password,
      Value<String?> phoneNumber,
      Value<bool> mustChangePassword,
      Value<String> role,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstname => $composableBuilder(
    column: $table.firstname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mustChangePassword => $composableBuilder(
    column: $table.mustChangePassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstname => $composableBuilder(
    column: $table.firstname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mustChangePassword => $composableBuilder(
    column: $table.mustChangePassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstname =>
      $composableBuilder(column: $table.firstname, builder: (column) => column);

  GeneratedColumn<String> get surname =>
      $composableBuilder(column: $table.surname, builder: (column) => column);

  GeneratedColumn<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get mustChangePassword => $composableBuilder(
    column: $table.mustChangePassword,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> firstname = const Value.absent(),
                Value<String?> surname = const Value.absent(),
                Value<String?> middleName = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> image = const Value.absent(),
                Value<String?> password = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<bool> mustChangePassword = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                firstname: firstname,
                surname: surname,
                middleName: middleName,
                name: name,
                email: email,
                image: image,
                password: password,
                phoneNumber: phoneNumber,
                mustChangePassword: mustChangePassword,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> firstname = const Value.absent(),
                Value<String?> surname = const Value.absent(),
                Value<String?> middleName = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> image = const Value.absent(),
                Value<String?> password = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<bool> mustChangePassword = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                firstname: firstname,
                surname: surname,
                middleName: middleName,
                name: name,
                email: email,
                image: image,
                password: password,
                phoneNumber: phoneNumber,
                mustChangePassword: mustChangePassword,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$FarmsTableCreateCompanionBuilder =
    FarmsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> location,
      required int capacity,
      required String userId,
      Value<String> subscriptionTier,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$FarmsTableUpdateCompanionBuilder =
    FarmsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> location,
      Value<int> capacity,
      Value<String> userId,
      Value<String> subscriptionTier,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$FarmsTableFilterComposer extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subscriptionTier => $composableBuilder(
    column: $table.subscriptionTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FarmsTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriptionTier => $composableBuilder(
    column: $table.subscriptionTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FarmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get subscriptionTier => $composableBuilder(
    column: $table.subscriptionTier,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FarmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmsTable,
          Farm,
          $$FarmsTableFilterComposer,
          $$FarmsTableOrderingComposer,
          $$FarmsTableAnnotationComposer,
          $$FarmsTableCreateCompanionBuilder,
          $$FarmsTableUpdateCompanionBuilder,
          (Farm, BaseReferences<_$AppDatabase, $FarmsTable, Farm>),
          Farm,
          PrefetchHooks Function()
        > {
  $$FarmsTableTableManager(_$AppDatabase db, $FarmsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> subscriptionTier = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FarmsCompanion(
                id: id,
                name: name,
                location: location,
                capacity: capacity,
                userId: userId,
                subscriptionTier: subscriptionTier,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> location = const Value.absent(),
                required int capacity,
                required String userId,
                Value<String> subscriptionTier = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FarmsCompanion.insert(
                id: id,
                name: name,
                location: location,
                capacity: capacity,
                userId: userId,
                subscriptionTier: subscriptionTier,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FarmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmsTable,
      Farm,
      $$FarmsTableFilterComposer,
      $$FarmsTableOrderingComposer,
      $$FarmsTableAnnotationComposer,
      $$FarmsTableCreateCompanionBuilder,
      $$FarmsTableUpdateCompanionBuilder,
      (Farm, BaseReferences<_$AppDatabase, $FarmsTable, Farm>),
      Farm,
      PrefetchHooks Function()
    >;
typedef $$BatchesTableCreateCompanionBuilder =
    BatchesCompanion Function({
      Value<int> id,
      required int farmId,
      Value<int?> houseId,
      Value<String?> userId,
      Value<String> batchName,
      Value<String> type,
      Value<String> status,
      Value<String?> breedType,
      required DateTime arrivalDate,
      required int currentCount,
      required int initialCount,
      Value<int> isolationCount,
      Value<double?> initialActualCost,
      Value<String?> growthTarget,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
    });
typedef $$BatchesTableUpdateCompanionBuilder =
    BatchesCompanion Function({
      Value<int> id,
      Value<int> farmId,
      Value<int?> houseId,
      Value<String?> userId,
      Value<String> batchName,
      Value<String> type,
      Value<String> status,
      Value<String?> breedType,
      Value<DateTime> arrivalDate,
      Value<int> currentCount,
      Value<int> initialCount,
      Value<int> isolationCount,
      Value<double?> initialActualCost,
      Value<String?> growthTarget,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
    });

class $$BatchesTableFilterComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchName => $composableBuilder(
    column: $table.batchName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breedType => $composableBuilder(
    column: $table.breedType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arrivalDate => $composableBuilder(
    column: $table.arrivalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialCount => $composableBuilder(
    column: $table.initialCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isolationCount => $composableBuilder(
    column: $table.isolationCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialActualCost => $composableBuilder(
    column: $table.initialActualCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get growthTarget => $composableBuilder(
    column: $table.growthTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchName => $composableBuilder(
    column: $table.batchName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breedType => $composableBuilder(
    column: $table.breedType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arrivalDate => $composableBuilder(
    column: $table.arrivalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialCount => $composableBuilder(
    column: $table.initialCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isolationCount => $composableBuilder(
    column: $table.isolationCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialActualCost => $composableBuilder(
    column: $table.initialActualCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get growthTarget => $composableBuilder(
    column: $table.growthTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<int> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get batchName =>
      $composableBuilder(column: $table.batchName, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get breedType =>
      $composableBuilder(column: $table.breedType, builder: (column) => column);

  GeneratedColumn<DateTime> get arrivalDate => $composableBuilder(
    column: $table.arrivalDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initialCount => $composableBuilder(
    column: $table.initialCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isolationCount => $composableBuilder(
    column: $table.isolationCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get initialActualCost => $composableBuilder(
    column: $table.initialActualCost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get growthTarget => $composableBuilder(
    column: $table.growthTarget,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$BatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatchesTable,
          Batch,
          $$BatchesTableFilterComposer,
          $$BatchesTableOrderingComposer,
          $$BatchesTableAnnotationComposer,
          $$BatchesTableCreateCompanionBuilder,
          $$BatchesTableUpdateCompanionBuilder,
          (Batch, BaseReferences<_$AppDatabase, $BatchesTable, Batch>),
          Batch,
          PrefetchHooks Function()
        > {
  $$BatchesTableTableManager(_$AppDatabase db, $BatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<int?> houseId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> batchName = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> breedType = const Value.absent(),
                Value<DateTime> arrivalDate = const Value.absent(),
                Value<int> currentCount = const Value.absent(),
                Value<int> initialCount = const Value.absent(),
                Value<int> isolationCount = const Value.absent(),
                Value<double?> initialActualCost = const Value.absent(),
                Value<String?> growthTarget = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => BatchesCompanion(
                id: id,
                farmId: farmId,
                houseId: houseId,
                userId: userId,
                batchName: batchName,
                type: type,
                status: status,
                breedType: breedType,
                arrivalDate: arrivalDate,
                currentCount: currentCount,
                initialCount: initialCount,
                isolationCount: isolationCount,
                initialActualCost: initialActualCost,
                growthTarget: growthTarget,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int farmId,
                Value<int?> houseId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> batchName = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> breedType = const Value.absent(),
                required DateTime arrivalDate,
                required int currentCount,
                required int initialCount,
                Value<int> isolationCount = const Value.absent(),
                Value<double?> initialActualCost = const Value.absent(),
                Value<String?> growthTarget = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => BatchesCompanion.insert(
                id: id,
                farmId: farmId,
                houseId: houseId,
                userId: userId,
                batchName: batchName,
                type: type,
                status: status,
                breedType: breedType,
                arrivalDate: arrivalDate,
                currentCount: currentCount,
                initialCount: initialCount,
                isolationCount: isolationCount,
                initialActualCost: initialActualCost,
                growthTarget: growthTarget,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatchesTable,
      Batch,
      $$BatchesTableFilterComposer,
      $$BatchesTableOrderingComposer,
      $$BatchesTableAnnotationComposer,
      $$BatchesTableCreateCompanionBuilder,
      $$BatchesTableUpdateCompanionBuilder,
      (Batch, BaseReferences<_$AppDatabase, $BatchesTable, Batch>),
      Batch,
      PrefetchHooks Function()
    >;
typedef $$InventoryTableCreateCompanionBuilder =
    InventoryCompanion Function({
      Value<int> id,
      required int farmId,
      Value<String?> userId,
      required String itemName,
      required double stockLevel,
      Value<double?> reorderLevel,
      required String unit,
      Value<String?> category,
      Value<double?> costPerUnit,
      Value<int?> supplierId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
    });
typedef $$InventoryTableUpdateCompanionBuilder =
    InventoryCompanion Function({
      Value<int> id,
      Value<int> farmId,
      Value<String?> userId,
      Value<String> itemName,
      Value<double> stockLevel,
      Value<double?> reorderLevel,
      Value<String> unit,
      Value<String?> category,
      Value<double?> costPerUnit,
      Value<int?> supplierId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
    });

class $$InventoryTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockLevel => $composableBuilder(
    column: $table.stockLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InventoryTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockLevel => $composableBuilder(
    column: $table.stockLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<double> get stockLevel => $composableBuilder(
    column: $table.stockLevel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$InventoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryTable,
          InventoryItem,
          $$InventoryTableFilterComposer,
          $$InventoryTableOrderingComposer,
          $$InventoryTableAnnotationComposer,
          $$InventoryTableCreateCompanionBuilder,
          $$InventoryTableUpdateCompanionBuilder,
          (
            InventoryItem,
            BaseReferences<_$AppDatabase, $InventoryTable, InventoryItem>,
          ),
          InventoryItem,
          PrefetchHooks Function()
        > {
  $$InventoryTableTableManager(_$AppDatabase db, $InventoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> itemName = const Value.absent(),
                Value<double> stockLevel = const Value.absent(),
                Value<double?> reorderLevel = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<double?> costPerUnit = const Value.absent(),
                Value<int?> supplierId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => InventoryCompanion(
                id: id,
                farmId: farmId,
                userId: userId,
                itemName: itemName,
                stockLevel: stockLevel,
                reorderLevel: reorderLevel,
                unit: unit,
                category: category,
                costPerUnit: costPerUnit,
                supplierId: supplierId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int farmId,
                Value<String?> userId = const Value.absent(),
                required String itemName,
                required double stockLevel,
                Value<double?> reorderLevel = const Value.absent(),
                required String unit,
                Value<String?> category = const Value.absent(),
                Value<double?> costPerUnit = const Value.absent(),
                Value<int?> supplierId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => InventoryCompanion.insert(
                id: id,
                farmId: farmId,
                userId: userId,
                itemName: itemName,
                stockLevel: stockLevel,
                reorderLevel: reorderLevel,
                unit: unit,
                category: category,
                costPerUnit: costPerUnit,
                supplierId: supplierId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InventoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryTable,
      InventoryItem,
      $$InventoryTableFilterComposer,
      $$InventoryTableOrderingComposer,
      $$InventoryTableAnnotationComposer,
      $$InventoryTableCreateCompanionBuilder,
      $$InventoryTableUpdateCompanionBuilder,
      (
        InventoryItem,
        BaseReferences<_$AppDatabase, $InventoryTable, InventoryItem>,
      ),
      InventoryItem,
      PrefetchHooks Function()
    >;
typedef $$FeedingLogsTableCreateCompanionBuilder =
    FeedingLogsCompanion Function({
      Value<int> id,
      required int farmId,
      Value<int?> batchId,
      Value<int?> feedTypeId,
      Value<int?> formulationId,
      required double amountConsumed,
      required DateTime logDate,
      Value<String?> userId,
      Value<bool> synced,
    });
typedef $$FeedingLogsTableUpdateCompanionBuilder =
    FeedingLogsCompanion Function({
      Value<int> id,
      Value<int> farmId,
      Value<int?> batchId,
      Value<int?> feedTypeId,
      Value<int?> formulationId,
      Value<double> amountConsumed,
      Value<DateTime> logDate,
      Value<String?> userId,
      Value<bool> synced,
    });

class $$FeedingLogsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedingLogsTable> {
  $$FeedingLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feedTypeId => $composableBuilder(
    column: $table.feedTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get formulationId => $composableBuilder(
    column: $table.formulationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountConsumed => $composableBuilder(
    column: $table.amountConsumed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedingLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedingLogsTable> {
  $$FeedingLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feedTypeId => $composableBuilder(
    column: $table.feedTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get formulationId => $composableBuilder(
    column: $table.formulationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountConsumed => $composableBuilder(
    column: $table.amountConsumed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedingLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedingLogsTable> {
  $$FeedingLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<int> get feedTypeId => $composableBuilder(
    column: $table.feedTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get formulationId => $composableBuilder(
    column: $table.formulationId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountConsumed => $composableBuilder(
    column: $table.amountConsumed,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$FeedingLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedingLogsTable,
          FeedingLog,
          $$FeedingLogsTableFilterComposer,
          $$FeedingLogsTableOrderingComposer,
          $$FeedingLogsTableAnnotationComposer,
          $$FeedingLogsTableCreateCompanionBuilder,
          $$FeedingLogsTableUpdateCompanionBuilder,
          (
            FeedingLog,
            BaseReferences<_$AppDatabase, $FeedingLogsTable, FeedingLog>,
          ),
          FeedingLog,
          PrefetchHooks Function()
        > {
  $$FeedingLogsTableTableManager(_$AppDatabase db, $FeedingLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedingLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedingLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedingLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
                Value<int?> feedTypeId = const Value.absent(),
                Value<int?> formulationId = const Value.absent(),
                Value<double> amountConsumed = const Value.absent(),
                Value<DateTime> logDate = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => FeedingLogsCompanion(
                id: id,
                farmId: farmId,
                batchId: batchId,
                feedTypeId: feedTypeId,
                formulationId: formulationId,
                amountConsumed: amountConsumed,
                logDate: logDate,
                userId: userId,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int farmId,
                Value<int?> batchId = const Value.absent(),
                Value<int?> feedTypeId = const Value.absent(),
                Value<int?> formulationId = const Value.absent(),
                required double amountConsumed,
                required DateTime logDate,
                Value<String?> userId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => FeedingLogsCompanion.insert(
                id: id,
                farmId: farmId,
                batchId: batchId,
                feedTypeId: feedTypeId,
                formulationId: formulationId,
                amountConsumed: amountConsumed,
                logDate: logDate,
                userId: userId,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedingLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedingLogsTable,
      FeedingLog,
      $$FeedingLogsTableFilterComposer,
      $$FeedingLogsTableOrderingComposer,
      $$FeedingLogsTableAnnotationComposer,
      $$FeedingLogsTableCreateCompanionBuilder,
      $$FeedingLogsTableUpdateCompanionBuilder,
      (
        FeedingLog,
        BaseReferences<_$AppDatabase, $FeedingLogsTable, FeedingLog>,
      ),
      FeedingLog,
      PrefetchHooks Function()
    >;
typedef $$EggProductionsTableCreateCompanionBuilder =
    EggProductionsCompanion Function({
      Value<int> id,
      required int farmId,
      required int batchId,
      Value<int?> categoryId,
      required int eggsCollected,
      Value<int> unusableCount,
      Value<int> eggsRemaining,
      Value<double?> cratesCollected,
      Value<String?> qualityGrade,
      required DateTime logDate,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<bool> synced,
    });
typedef $$EggProductionsTableUpdateCompanionBuilder =
    EggProductionsCompanion Function({
      Value<int> id,
      Value<int> farmId,
      Value<int> batchId,
      Value<int?> categoryId,
      Value<int> eggsCollected,
      Value<int> unusableCount,
      Value<int> eggsRemaining,
      Value<double?> cratesCollected,
      Value<String?> qualityGrade,
      Value<DateTime> logDate,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<bool> synced,
    });

class $$EggProductionsTableFilterComposer
    extends Composer<_$AppDatabase, $EggProductionsTable> {
  $$EggProductionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eggsCollected => $composableBuilder(
    column: $table.eggsCollected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unusableCount => $composableBuilder(
    column: $table.unusableCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eggsRemaining => $composableBuilder(
    column: $table.eggsRemaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cratesCollected => $composableBuilder(
    column: $table.cratesCollected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qualityGrade => $composableBuilder(
    column: $table.qualityGrade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EggProductionsTableOrderingComposer
    extends Composer<_$AppDatabase, $EggProductionsTable> {
  $$EggProductionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eggsCollected => $composableBuilder(
    column: $table.eggsCollected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unusableCount => $composableBuilder(
    column: $table.unusableCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eggsRemaining => $composableBuilder(
    column: $table.eggsRemaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cratesCollected => $composableBuilder(
    column: $table.cratesCollected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qualityGrade => $composableBuilder(
    column: $table.qualityGrade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EggProductionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EggProductionsTable> {
  $$EggProductionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eggsCollected => $composableBuilder(
    column: $table.eggsCollected,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unusableCount => $composableBuilder(
    column: $table.unusableCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eggsRemaining => $composableBuilder(
    column: $table.eggsRemaining,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cratesCollected => $composableBuilder(
    column: $table.cratesCollected,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qualityGrade => $composableBuilder(
    column: $table.qualityGrade,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$EggProductionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EggProductionsTable,
          EggProduction,
          $$EggProductionsTableFilterComposer,
          $$EggProductionsTableOrderingComposer,
          $$EggProductionsTableAnnotationComposer,
          $$EggProductionsTableCreateCompanionBuilder,
          $$EggProductionsTableUpdateCompanionBuilder,
          (
            EggProduction,
            BaseReferences<_$AppDatabase, $EggProductionsTable, EggProduction>,
          ),
          EggProduction,
          PrefetchHooks Function()
        > {
  $$EggProductionsTableTableManager(
    _$AppDatabase db,
    $EggProductionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EggProductionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EggProductionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EggProductionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<int> batchId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int> eggsCollected = const Value.absent(),
                Value<int> unusableCount = const Value.absent(),
                Value<int> eggsRemaining = const Value.absent(),
                Value<double?> cratesCollected = const Value.absent(),
                Value<String?> qualityGrade = const Value.absent(),
                Value<DateTime> logDate = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => EggProductionsCompanion(
                id: id,
                farmId: farmId,
                batchId: batchId,
                categoryId: categoryId,
                eggsCollected: eggsCollected,
                unusableCount: unusableCount,
                eggsRemaining: eggsRemaining,
                cratesCollected: cratesCollected,
                qualityGrade: qualityGrade,
                logDate: logDate,
                userId: userId,
                createdAt: createdAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int farmId,
                required int batchId,
                Value<int?> categoryId = const Value.absent(),
                required int eggsCollected,
                Value<int> unusableCount = const Value.absent(),
                Value<int> eggsRemaining = const Value.absent(),
                Value<double?> cratesCollected = const Value.absent(),
                Value<String?> qualityGrade = const Value.absent(),
                required DateTime logDate,
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => EggProductionsCompanion.insert(
                id: id,
                farmId: farmId,
                batchId: batchId,
                categoryId: categoryId,
                eggsCollected: eggsCollected,
                unusableCount: unusableCount,
                eggsRemaining: eggsRemaining,
                cratesCollected: cratesCollected,
                qualityGrade: qualityGrade,
                logDate: logDate,
                userId: userId,
                createdAt: createdAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EggProductionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EggProductionsTable,
      EggProduction,
      $$EggProductionsTableFilterComposer,
      $$EggProductionsTableOrderingComposer,
      $$EggProductionsTableAnnotationComposer,
      $$EggProductionsTableCreateCompanionBuilder,
      $$EggProductionsTableUpdateCompanionBuilder,
      (
        EggProduction,
        BaseReferences<_$AppDatabase, $EggProductionsTable, EggProduction>,
      ),
      EggProduction,
      PrefetchHooks Function()
    >;
typedef $$MortalitiesTableCreateCompanionBuilder =
    MortalitiesCompanion Function({
      Value<int> id,
      required int farmId,
      required int batchId,
      required int count,
      Value<String?> reason,
      Value<String?> category,
      Value<String?> subCategory,
      required DateTime logDate,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<bool> synced,
    });
typedef $$MortalitiesTableUpdateCompanionBuilder =
    MortalitiesCompanion Function({
      Value<int> id,
      Value<int> farmId,
      Value<int> batchId,
      Value<int> count,
      Value<String?> reason,
      Value<String?> category,
      Value<String?> subCategory,
      Value<DateTime> logDate,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<bool> synced,
    });

class $$MortalitiesTableFilterComposer
    extends Composer<_$AppDatabase, $MortalitiesTable> {
  $$MortalitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subCategory => $composableBuilder(
    column: $table.subCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MortalitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $MortalitiesTable> {
  $$MortalitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subCategory => $composableBuilder(
    column: $table.subCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MortalitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MortalitiesTable> {
  $$MortalitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subCategory => $composableBuilder(
    column: $table.subCategory,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$MortalitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MortalitiesTable,
          Mortality,
          $$MortalitiesTableFilterComposer,
          $$MortalitiesTableOrderingComposer,
          $$MortalitiesTableAnnotationComposer,
          $$MortalitiesTableCreateCompanionBuilder,
          $$MortalitiesTableUpdateCompanionBuilder,
          (
            Mortality,
            BaseReferences<_$AppDatabase, $MortalitiesTable, Mortality>,
          ),
          Mortality,
          PrefetchHooks Function()
        > {
  $$MortalitiesTableTableManager(_$AppDatabase db, $MortalitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MortalitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MortalitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MortalitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<int> batchId = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> subCategory = const Value.absent(),
                Value<DateTime> logDate = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => MortalitiesCompanion(
                id: id,
                farmId: farmId,
                batchId: batchId,
                count: count,
                reason: reason,
                category: category,
                subCategory: subCategory,
                logDate: logDate,
                userId: userId,
                createdAt: createdAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int farmId,
                required int batchId,
                required int count,
                Value<String?> reason = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> subCategory = const Value.absent(),
                required DateTime logDate,
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => MortalitiesCompanion.insert(
                id: id,
                farmId: farmId,
                batchId: batchId,
                count: count,
                reason: reason,
                category: category,
                subCategory: subCategory,
                logDate: logDate,
                userId: userId,
                createdAt: createdAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MortalitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MortalitiesTable,
      Mortality,
      $$MortalitiesTableFilterComposer,
      $$MortalitiesTableOrderingComposer,
      $$MortalitiesTableAnnotationComposer,
      $$MortalitiesTableCreateCompanionBuilder,
      $$MortalitiesTableUpdateCompanionBuilder,
      (Mortality, BaseReferences<_$AppDatabase, $MortalitiesTable, Mortality>),
      Mortality,
      PrefetchHooks Function()
    >;
typedef $$HousesTableCreateCompanionBuilder =
    HousesCompanion Function({
      Value<int> id,
      required int farmId,
      Value<String?> userId,
      required String name,
      required int capacity,
      Value<double?> currentTemperature,
      Value<double?> currentHumidity,
      Value<bool> isIsolation,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
    });
typedef $$HousesTableUpdateCompanionBuilder =
    HousesCompanion Function({
      Value<int> id,
      Value<int> farmId,
      Value<String?> userId,
      Value<String> name,
      Value<int> capacity,
      Value<double?> currentTemperature,
      Value<double?> currentHumidity,
      Value<bool> isIsolation,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
    });

class $$HousesTableFilterComposer
    extends Composer<_$AppDatabase, $HousesTable> {
  $$HousesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentTemperature => $composableBuilder(
    column: $table.currentTemperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentHumidity => $composableBuilder(
    column: $table.currentHumidity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIsolation => $composableBuilder(
    column: $table.isIsolation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HousesTableOrderingComposer
    extends Composer<_$AppDatabase, $HousesTable> {
  $$HousesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentTemperature => $composableBuilder(
    column: $table.currentTemperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentHumidity => $composableBuilder(
    column: $table.currentHumidity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIsolation => $composableBuilder(
    column: $table.isIsolation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HousesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HousesTable> {
  $$HousesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<double> get currentTemperature => $composableBuilder(
    column: $table.currentTemperature,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentHumidity => $composableBuilder(
    column: $table.currentHumidity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIsolation => $composableBuilder(
    column: $table.isIsolation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$HousesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HousesTable,
          House,
          $$HousesTableFilterComposer,
          $$HousesTableOrderingComposer,
          $$HousesTableAnnotationComposer,
          $$HousesTableCreateCompanionBuilder,
          $$HousesTableUpdateCompanionBuilder,
          (House, BaseReferences<_$AppDatabase, $HousesTable, House>),
          House,
          PrefetchHooks Function()
        > {
  $$HousesTableTableManager(_$AppDatabase db, $HousesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HousesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HousesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HousesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<double?> currentTemperature = const Value.absent(),
                Value<double?> currentHumidity = const Value.absent(),
                Value<bool> isIsolation = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => HousesCompanion(
                id: id,
                farmId: farmId,
                userId: userId,
                name: name,
                capacity: capacity,
                currentTemperature: currentTemperature,
                currentHumidity: currentHumidity,
                isIsolation: isIsolation,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int farmId,
                Value<String?> userId = const Value.absent(),
                required String name,
                required int capacity,
                Value<double?> currentTemperature = const Value.absent(),
                Value<double?> currentHumidity = const Value.absent(),
                Value<bool> isIsolation = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => HousesCompanion.insert(
                id: id,
                farmId: farmId,
                userId: userId,
                name: name,
                capacity: capacity,
                currentTemperature: currentTemperature,
                currentHumidity: currentHumidity,
                isIsolation: isIsolation,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HousesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HousesTable,
      House,
      $$HousesTableFilterComposer,
      $$HousesTableOrderingComposer,
      $$HousesTableAnnotationComposer,
      $$HousesTableCreateCompanionBuilder,
      $$HousesTableUpdateCompanionBuilder,
      (House, BaseReferences<_$AppDatabase, $HousesTable, House>),
      House,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      required int farmId,
      required String name,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> address,
      Value<double> balanceOwed,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      Value<int> farmId,
      Value<String> name,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> address,
      Value<double> balanceOwed,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
    });

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balanceOwed => $composableBuilder(
    column: $table.balanceOwed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balanceOwed => $composableBuilder(
    column: $table.balanceOwed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get balanceOwed => $composableBuilder(
    column: $table.balanceOwed,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
          Customer,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<double> balanceOwed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                farmId: farmId,
                name: name,
                phone: phone,
                email: email,
                address: address,
                balanceOwed: balanceOwed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int farmId,
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<double> balanceOwed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                farmId: farmId,
                name: name,
                phone: phone,
                email: email,
                address: address,
                balanceOwed: balanceOwed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
      Customer,
      PrefetchHooks Function()
    >;
typedef $$FarmSettingsTableCreateCompanionBuilder =
    FarmSettingsCompanion Function({
      Value<int> id,
      required int farmId,
      Value<String> currency,
      Value<String?> eggRecordReminderTime,
      Value<String?> feedRecordReminderTime,
      Value<int?> growthTargetStandard,
      Value<int> eggsPerCrate,
    });
typedef $$FarmSettingsTableUpdateCompanionBuilder =
    FarmSettingsCompanion Function({
      Value<int> id,
      Value<int> farmId,
      Value<String> currency,
      Value<String?> eggRecordReminderTime,
      Value<String?> feedRecordReminderTime,
      Value<int?> growthTargetStandard,
      Value<int> eggsPerCrate,
    });

class $$FarmSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $FarmSettingsTable> {
  $$FarmSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eggRecordReminderTime => $composableBuilder(
    column: $table.eggRecordReminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedRecordReminderTime => $composableBuilder(
    column: $table.feedRecordReminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get growthTargetStandard => $composableBuilder(
    column: $table.growthTargetStandard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eggsPerCrate => $composableBuilder(
    column: $table.eggsPerCrate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FarmSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmSettingsTable> {
  $$FarmSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eggRecordReminderTime => $composableBuilder(
    column: $table.eggRecordReminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedRecordReminderTime => $composableBuilder(
    column: $table.feedRecordReminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get growthTargetStandard => $composableBuilder(
    column: $table.growthTargetStandard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eggsPerCrate => $composableBuilder(
    column: $table.eggsPerCrate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FarmSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmSettingsTable> {
  $$FarmSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get eggRecordReminderTime => $composableBuilder(
    column: $table.eggRecordReminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedRecordReminderTime => $composableBuilder(
    column: $table.feedRecordReminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get growthTargetStandard => $composableBuilder(
    column: $table.growthTargetStandard,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eggsPerCrate => $composableBuilder(
    column: $table.eggsPerCrate,
    builder: (column) => column,
  );
}

class $$FarmSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmSettingsTable,
          FarmSetting,
          $$FarmSettingsTableFilterComposer,
          $$FarmSettingsTableOrderingComposer,
          $$FarmSettingsTableAnnotationComposer,
          $$FarmSettingsTableCreateCompanionBuilder,
          $$FarmSettingsTableUpdateCompanionBuilder,
          (
            FarmSetting,
            BaseReferences<_$AppDatabase, $FarmSettingsTable, FarmSetting>,
          ),
          FarmSetting,
          PrefetchHooks Function()
        > {
  $$FarmSettingsTableTableManager(_$AppDatabase db, $FarmSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> eggRecordReminderTime = const Value.absent(),
                Value<String?> feedRecordReminderTime = const Value.absent(),
                Value<int?> growthTargetStandard = const Value.absent(),
                Value<int> eggsPerCrate = const Value.absent(),
              }) => FarmSettingsCompanion(
                id: id,
                farmId: farmId,
                currency: currency,
                eggRecordReminderTime: eggRecordReminderTime,
                feedRecordReminderTime: feedRecordReminderTime,
                growthTargetStandard: growthTargetStandard,
                eggsPerCrate: eggsPerCrate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int farmId,
                Value<String> currency = const Value.absent(),
                Value<String?> eggRecordReminderTime = const Value.absent(),
                Value<String?> feedRecordReminderTime = const Value.absent(),
                Value<int?> growthTargetStandard = const Value.absent(),
                Value<int> eggsPerCrate = const Value.absent(),
              }) => FarmSettingsCompanion.insert(
                id: id,
                farmId: farmId,
                currency: currency,
                eggRecordReminderTime: eggRecordReminderTime,
                feedRecordReminderTime: feedRecordReminderTime,
                growthTargetStandard: growthTargetStandard,
                eggsPerCrate: eggsPerCrate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FarmSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmSettingsTable,
      FarmSetting,
      $$FarmSettingsTableFilterComposer,
      $$FarmSettingsTableOrderingComposer,
      $$FarmSettingsTableAnnotationComposer,
      $$FarmSettingsTableCreateCompanionBuilder,
      $$FarmSettingsTableUpdateCompanionBuilder,
      (
        FarmSetting,
        BaseReferences<_$AppDatabase, $FarmSettingsTable, FarmSetting>,
      ),
      FarmSetting,
      PrefetchHooks Function()
    >;
typedef $$WeightRecordsTableCreateCompanionBuilder =
    WeightRecordsCompanion Function({
      Value<int> id,
      required int farmId,
      required int batchId,
      required double averageWeight,
      required DateTime logDate,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<bool> synced,
    });
typedef $$WeightRecordsTableUpdateCompanionBuilder =
    WeightRecordsCompanion Function({
      Value<int> id,
      Value<int> farmId,
      Value<int> batchId,
      Value<double> averageWeight,
      Value<DateTime> logDate,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<bool> synced,
    });

class $$WeightRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WeightRecordsTable> {
  $$WeightRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageWeight => $composableBuilder(
    column: $table.averageWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightRecordsTable> {
  $$WeightRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageWeight => $composableBuilder(
    column: $table.averageWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightRecordsTable> {
  $$WeightRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<double> get averageWeight => $composableBuilder(
    column: $table.averageWeight,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$WeightRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightRecordsTable,
          WeightRecord,
          $$WeightRecordsTableFilterComposer,
          $$WeightRecordsTableOrderingComposer,
          $$WeightRecordsTableAnnotationComposer,
          $$WeightRecordsTableCreateCompanionBuilder,
          $$WeightRecordsTableUpdateCompanionBuilder,
          (
            WeightRecord,
            BaseReferences<_$AppDatabase, $WeightRecordsTable, WeightRecord>,
          ),
          WeightRecord,
          PrefetchHooks Function()
        > {
  $$WeightRecordsTableTableManager(_$AppDatabase db, $WeightRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<int> batchId = const Value.absent(),
                Value<double> averageWeight = const Value.absent(),
                Value<DateTime> logDate = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => WeightRecordsCompanion(
                id: id,
                farmId: farmId,
                batchId: batchId,
                averageWeight: averageWeight,
                logDate: logDate,
                userId: userId,
                createdAt: createdAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int farmId,
                required int batchId,
                required double averageWeight,
                required DateTime logDate,
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => WeightRecordsCompanion.insert(
                id: id,
                farmId: farmId,
                batchId: batchId,
                averageWeight: averageWeight,
                logDate: logDate,
                userId: userId,
                createdAt: createdAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightRecordsTable,
      WeightRecord,
      $$WeightRecordsTableFilterComposer,
      $$WeightRecordsTableOrderingComposer,
      $$WeightRecordsTableAnnotationComposer,
      $$WeightRecordsTableCreateCompanionBuilder,
      $$WeightRecordsTableUpdateCompanionBuilder,
      (
        WeightRecord,
        BaseReferences<_$AppDatabase, $WeightRecordsTable, WeightRecord>,
      ),
      WeightRecord,
      PrefetchHooks Function()
    >;
typedef $$DeviceRegistrationsTableCreateCompanionBuilder =
    DeviceRegistrationsCompanion Function({
      required String id,
      required int farmId,
      required String userId,
      required String deviceIdentifier,
      Value<String?> deviceName,
      Value<DateTime> registeredAt,
      Value<int> rowid,
    });
typedef $$DeviceRegistrationsTableUpdateCompanionBuilder =
    DeviceRegistrationsCompanion Function({
      Value<String> id,
      Value<int> farmId,
      Value<String> userId,
      Value<String> deviceIdentifier,
      Value<String?> deviceName,
      Value<DateTime> registeredAt,
      Value<int> rowid,
    });

class $$DeviceRegistrationsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceRegistrationsTable> {
  $$DeviceRegistrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceIdentifier => $composableBuilder(
    column: $table.deviceIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviceRegistrationsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceRegistrationsTable> {
  $$DeviceRegistrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceIdentifier => $composableBuilder(
    column: $table.deviceIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceRegistrationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceRegistrationsTable> {
  $$DeviceRegistrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceIdentifier => $composableBuilder(
    column: $table.deviceIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => column,
  );
}

class $$DeviceRegistrationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceRegistrationsTable,
          DeviceRegistration,
          $$DeviceRegistrationsTableFilterComposer,
          $$DeviceRegistrationsTableOrderingComposer,
          $$DeviceRegistrationsTableAnnotationComposer,
          $$DeviceRegistrationsTableCreateCompanionBuilder,
          $$DeviceRegistrationsTableUpdateCompanionBuilder,
          (
            DeviceRegistration,
            BaseReferences<
              _$AppDatabase,
              $DeviceRegistrationsTable,
              DeviceRegistration
            >,
          ),
          DeviceRegistration,
          PrefetchHooks Function()
        > {
  $$DeviceRegistrationsTableTableManager(
    _$AppDatabase db,
    $DeviceRegistrationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceRegistrationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceRegistrationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DeviceRegistrationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> deviceIdentifier = const Value.absent(),
                Value<String?> deviceName = const Value.absent(),
                Value<DateTime> registeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceRegistrationsCompanion(
                id: id,
                farmId: farmId,
                userId: userId,
                deviceIdentifier: deviceIdentifier,
                deviceName: deviceName,
                registeredAt: registeredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int farmId,
                required String userId,
                required String deviceIdentifier,
                Value<String?> deviceName = const Value.absent(),
                Value<DateTime> registeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceRegistrationsCompanion.insert(
                id: id,
                farmId: farmId,
                userId: userId,
                deviceIdentifier: deviceIdentifier,
                deviceName: deviceName,
                registeredAt: registeredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceRegistrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceRegistrationsTable,
      DeviceRegistration,
      $$DeviceRegistrationsTableFilterComposer,
      $$DeviceRegistrationsTableOrderingComposer,
      $$DeviceRegistrationsTableAnnotationComposer,
      $$DeviceRegistrationsTableCreateCompanionBuilder,
      $$DeviceRegistrationsTableUpdateCompanionBuilder,
      (
        DeviceRegistration,
        BaseReferences<
          _$AppDatabase,
          $DeviceRegistrationsTable,
          DeviceRegistration
        >,
      ),
      DeviceRegistration,
      PrefetchHooks Function()
    >;
typedef $$FarmMembersTableCreateCompanionBuilder =
    FarmMembersCompanion Function({
      Value<int> id,
      required int farmId,
      required String userId,
      Value<String> role,
      Value<DateTime> joinedAt,
    });
typedef $$FarmMembersTableUpdateCompanionBuilder =
    FarmMembersCompanion Function({
      Value<int> id,
      Value<int> farmId,
      Value<String> userId,
      Value<String> role,
      Value<DateTime> joinedAt,
    });

class $$FarmMembersTableFilterComposer
    extends Composer<_$AppDatabase, $FarmMembersTable> {
  $$FarmMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FarmMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmMembersTable> {
  $$FarmMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FarmMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmMembersTable> {
  $$FarmMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);
}

class $$FarmMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmMembersTable,
          FarmMember,
          $$FarmMembersTableFilterComposer,
          $$FarmMembersTableOrderingComposer,
          $$FarmMembersTableAnnotationComposer,
          $$FarmMembersTableCreateCompanionBuilder,
          $$FarmMembersTableUpdateCompanionBuilder,
          (
            FarmMember,
            BaseReferences<_$AppDatabase, $FarmMembersTable, FarmMember>,
          ),
          FarmMember,
          PrefetchHooks Function()
        > {
  $$FarmMembersTableTableManager(_$AppDatabase db, $FarmMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
              }) => FarmMembersCompanion(
                id: id,
                farmId: farmId,
                userId: userId,
                role: role,
                joinedAt: joinedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int farmId,
                required String userId,
                Value<String> role = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
              }) => FarmMembersCompanion.insert(
                id: id,
                farmId: farmId,
                userId: userId,
                role: role,
                joinedAt: joinedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FarmMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmMembersTable,
      FarmMember,
      $$FarmMembersTableFilterComposer,
      $$FarmMembersTableOrderingComposer,
      $$FarmMembersTableAnnotationComposer,
      $$FarmMembersTableCreateCompanionBuilder,
      $$FarmMembersTableUpdateCompanionBuilder,
      (
        FarmMember,
        BaseReferences<_$AppDatabase, $FarmMembersTable, FarmMember>,
      ),
      FarmMember,
      PrefetchHooks Function()
    >;
typedef $$FeedTypesTableCreateCompanionBuilder =
    FeedTypesCompanion Function({
      Value<int> id,
      required int farmId,
      required String name,
      Value<String?> description,
    });
typedef $$FeedTypesTableUpdateCompanionBuilder =
    FeedTypesCompanion Function({
      Value<int> id,
      Value<int> farmId,
      Value<String> name,
      Value<String?> description,
    });

class $$FeedTypesTableFilterComposer
    extends Composer<_$AppDatabase, $FeedTypesTable> {
  $$FeedTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedTypesTable> {
  $$FeedTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedTypesTable> {
  $$FeedTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$FeedTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedTypesTable,
          FeedType,
          $$FeedTypesTableFilterComposer,
          $$FeedTypesTableOrderingComposer,
          $$FeedTypesTableAnnotationComposer,
          $$FeedTypesTableCreateCompanionBuilder,
          $$FeedTypesTableUpdateCompanionBuilder,
          (FeedType, BaseReferences<_$AppDatabase, $FeedTypesTable, FeedType>),
          FeedType,
          PrefetchHooks Function()
        > {
  $$FeedTypesTableTableManager(_$AppDatabase db, $FeedTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) => FeedTypesCompanion(
                id: id,
                farmId: farmId,
                name: name,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int farmId,
                required String name,
                Value<String?> description = const Value.absent(),
              }) => FeedTypesCompanion.insert(
                id: id,
                farmId: farmId,
                name: name,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedTypesTable,
      FeedType,
      $$FeedTypesTableFilterComposer,
      $$FeedTypesTableOrderingComposer,
      $$FeedTypesTableAnnotationComposer,
      $$FeedTypesTableCreateCompanionBuilder,
      $$FeedTypesTableUpdateCompanionBuilder,
      (FeedType, BaseReferences<_$AppDatabase, $FeedTypesTable, FeedType>),
      FeedType,
      PrefetchHooks Function()
    >;
typedef $$FeedFormulationsTableCreateCompanionBuilder =
    FeedFormulationsCompanion Function({
      Value<int> id,
      required int farmId,
      required String name,
      Value<String?> ingredientsJson,
    });
typedef $$FeedFormulationsTableUpdateCompanionBuilder =
    FeedFormulationsCompanion Function({
      Value<int> id,
      Value<int> farmId,
      Value<String> name,
      Value<String?> ingredientsJson,
    });

class $$FeedFormulationsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedFormulationsTable> {
  $$FeedFormulationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientsJson => $composableBuilder(
    column: $table.ingredientsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedFormulationsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedFormulationsTable> {
  $$FeedFormulationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientsJson => $composableBuilder(
    column: $table.ingredientsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedFormulationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedFormulationsTable> {
  $$FeedFormulationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get ingredientsJson => $composableBuilder(
    column: $table.ingredientsJson,
    builder: (column) => column,
  );
}

class $$FeedFormulationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedFormulationsTable,
          FeedFormulation,
          $$FeedFormulationsTableFilterComposer,
          $$FeedFormulationsTableOrderingComposer,
          $$FeedFormulationsTableAnnotationComposer,
          $$FeedFormulationsTableCreateCompanionBuilder,
          $$FeedFormulationsTableUpdateCompanionBuilder,
          (
            FeedFormulation,
            BaseReferences<
              _$AppDatabase,
              $FeedFormulationsTable,
              FeedFormulation
            >,
          ),
          FeedFormulation,
          PrefetchHooks Function()
        > {
  $$FeedFormulationsTableTableManager(
    _$AppDatabase db,
    $FeedFormulationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedFormulationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedFormulationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedFormulationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> ingredientsJson = const Value.absent(),
              }) => FeedFormulationsCompanion(
                id: id,
                farmId: farmId,
                name: name,
                ingredientsJson: ingredientsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int farmId,
                required String name,
                Value<String?> ingredientsJson = const Value.absent(),
              }) => FeedFormulationsCompanion.insert(
                id: id,
                farmId: farmId,
                name: name,
                ingredientsJson: ingredientsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedFormulationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedFormulationsTable,
      FeedFormulation,
      $$FeedFormulationsTableFilterComposer,
      $$FeedFormulationsTableOrderingComposer,
      $$FeedFormulationsTableAnnotationComposer,
      $$FeedFormulationsTableCreateCompanionBuilder,
      $$FeedFormulationsTableUpdateCompanionBuilder,
      (
        FeedFormulation,
        BaseReferences<_$AppDatabase, $FeedFormulationsTable, FeedFormulation>,
      ),
      FeedFormulation,
      PrefetchHooks Function()
    >;
typedef $$VaccinationSchedulesTableCreateCompanionBuilder =
    VaccinationSchedulesCompanion Function({
      Value<int> id,
      required int batchId,
      required String vaccineName,
      required DateTime scheduledDate,
      Value<String> status,
      Value<String?> notes,
      required int farmId,
      Value<bool> synced,
    });
typedef $$VaccinationSchedulesTableUpdateCompanionBuilder =
    VaccinationSchedulesCompanion Function({
      Value<int> id,
      Value<int> batchId,
      Value<String> vaccineName,
      Value<DateTime> scheduledDate,
      Value<String> status,
      Value<String?> notes,
      Value<int> farmId,
      Value<bool> synced,
    });

class $$VaccinationSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $VaccinationSchedulesTable> {
  $$VaccinationSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vaccineName => $composableBuilder(
    column: $table.vaccineName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaccinationSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $VaccinationSchedulesTable> {
  $$VaccinationSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vaccineName => $composableBuilder(
    column: $table.vaccineName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaccinationSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaccinationSchedulesTable> {
  $$VaccinationSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get vaccineName => $composableBuilder(
    column: $table.vaccineName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$VaccinationSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VaccinationSchedulesTable,
          VaccinationSchedule,
          $$VaccinationSchedulesTableFilterComposer,
          $$VaccinationSchedulesTableOrderingComposer,
          $$VaccinationSchedulesTableAnnotationComposer,
          $$VaccinationSchedulesTableCreateCompanionBuilder,
          $$VaccinationSchedulesTableUpdateCompanionBuilder,
          (
            VaccinationSchedule,
            BaseReferences<
              _$AppDatabase,
              $VaccinationSchedulesTable,
              VaccinationSchedule
            >,
          ),
          VaccinationSchedule,
          PrefetchHooks Function()
        > {
  $$VaccinationSchedulesTableTableManager(
    _$AppDatabase db,
    $VaccinationSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaccinationSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaccinationSchedulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VaccinationSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> batchId = const Value.absent(),
                Value<String> vaccineName = const Value.absent(),
                Value<DateTime> scheduledDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => VaccinationSchedulesCompanion(
                id: id,
                batchId: batchId,
                vaccineName: vaccineName,
                scheduledDate: scheduledDate,
                status: status,
                notes: notes,
                farmId: farmId,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int batchId,
                required String vaccineName,
                required DateTime scheduledDate,
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int farmId,
                Value<bool> synced = const Value.absent(),
              }) => VaccinationSchedulesCompanion.insert(
                id: id,
                batchId: batchId,
                vaccineName: vaccineName,
                scheduledDate: scheduledDate,
                status: status,
                notes: notes,
                farmId: farmId,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaccinationSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VaccinationSchedulesTable,
      VaccinationSchedule,
      $$VaccinationSchedulesTableFilterComposer,
      $$VaccinationSchedulesTableOrderingComposer,
      $$VaccinationSchedulesTableAnnotationComposer,
      $$VaccinationSchedulesTableCreateCompanionBuilder,
      $$VaccinationSchedulesTableUpdateCompanionBuilder,
      (
        VaccinationSchedule,
        BaseReferences<
          _$AppDatabase,
          $VaccinationSchedulesTable,
          VaccinationSchedule
        >,
      ),
      VaccinationSchedule,
      PrefetchHooks Function()
    >;
typedef $$MedicationSchedulesTableCreateCompanionBuilder =
    MedicationSchedulesCompanion Function({
      Value<int> id,
      required int batchId,
      required String medicationName,
      required DateTime scheduledDate,
      Value<String> status,
      Value<String?> notes,
      required int farmId,
      Value<bool> synced,
    });
typedef $$MedicationSchedulesTableUpdateCompanionBuilder =
    MedicationSchedulesCompanion Function({
      Value<int> id,
      Value<int> batchId,
      Value<String> medicationName,
      Value<DateTime> scheduledDate,
      Value<String> status,
      Value<String?> notes,
      Value<int> farmId,
      Value<bool> synced,
    });

class $$MedicationSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicationSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationSchedulesTable> {
  $$MedicationSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$MedicationSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationSchedulesTable,
          MedicationSchedule,
          $$MedicationSchedulesTableFilterComposer,
          $$MedicationSchedulesTableOrderingComposer,
          $$MedicationSchedulesTableAnnotationComposer,
          $$MedicationSchedulesTableCreateCompanionBuilder,
          $$MedicationSchedulesTableUpdateCompanionBuilder,
          (
            MedicationSchedule,
            BaseReferences<
              _$AppDatabase,
              $MedicationSchedulesTable,
              MedicationSchedule
            >,
          ),
          MedicationSchedule,
          PrefetchHooks Function()
        > {
  $$MedicationSchedulesTableTableManager(
    _$AppDatabase db,
    $MedicationSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationSchedulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MedicationSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> batchId = const Value.absent(),
                Value<String> medicationName = const Value.absent(),
                Value<DateTime> scheduledDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> farmId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => MedicationSchedulesCompanion(
                id: id,
                batchId: batchId,
                medicationName: medicationName,
                scheduledDate: scheduledDate,
                status: status,
                notes: notes,
                farmId: farmId,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int batchId,
                required String medicationName,
                required DateTime scheduledDate,
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int farmId,
                Value<bool> synced = const Value.absent(),
              }) => MedicationSchedulesCompanion.insert(
                id: id,
                batchId: batchId,
                medicationName: medicationName,
                scheduledDate: scheduledDate,
                status: status,
                notes: notes,
                farmId: farmId,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicationSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationSchedulesTable,
      MedicationSchedule,
      $$MedicationSchedulesTableFilterComposer,
      $$MedicationSchedulesTableOrderingComposer,
      $$MedicationSchedulesTableAnnotationComposer,
      $$MedicationSchedulesTableCreateCompanionBuilder,
      $$MedicationSchedulesTableUpdateCompanionBuilder,
      (
        MedicationSchedule,
        BaseReferences<
          _$AppDatabase,
          $MedicationSchedulesTable,
          MedicationSchedule
        >,
      ),
      MedicationSchedule,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$FarmsTableTableManager get farms =>
      $$FarmsTableTableManager(_db, _db.farms);
  $$BatchesTableTableManager get batches =>
      $$BatchesTableTableManager(_db, _db.batches);
  $$InventoryTableTableManager get inventory =>
      $$InventoryTableTableManager(_db, _db.inventory);
  $$FeedingLogsTableTableManager get feedingLogs =>
      $$FeedingLogsTableTableManager(_db, _db.feedingLogs);
  $$EggProductionsTableTableManager get eggProductions =>
      $$EggProductionsTableTableManager(_db, _db.eggProductions);
  $$MortalitiesTableTableManager get mortalities =>
      $$MortalitiesTableTableManager(_db, _db.mortalities);
  $$HousesTableTableManager get houses =>
      $$HousesTableTableManager(_db, _db.houses);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$FarmSettingsTableTableManager get farmSettings =>
      $$FarmSettingsTableTableManager(_db, _db.farmSettings);
  $$WeightRecordsTableTableManager get weightRecords =>
      $$WeightRecordsTableTableManager(_db, _db.weightRecords);
  $$DeviceRegistrationsTableTableManager get deviceRegistrations =>
      $$DeviceRegistrationsTableTableManager(_db, _db.deviceRegistrations);
  $$FarmMembersTableTableManager get farmMembers =>
      $$FarmMembersTableTableManager(_db, _db.farmMembers);
  $$FeedTypesTableTableManager get feedTypes =>
      $$FeedTypesTableTableManager(_db, _db.feedTypes);
  $$FeedFormulationsTableTableManager get feedFormulations =>
      $$FeedFormulationsTableTableManager(_db, _db.feedFormulations);
  $$VaccinationSchedulesTableTableManager get vaccinationSchedules =>
      $$VaccinationSchedulesTableTableManager(_db, _db.vaccinationSchedules);
  $$MedicationSchedulesTableTableManager get medicationSchedules =>
      $$MedicationSchedulesTableTableManager(_db, _db.medicationSchedules);
}
