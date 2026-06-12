import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

const workerPlaceholderPassword = '123456';

class PermissionDefinition {
  final String key;
  final String label;
  final String group;

  const PermissionDefinition({
    required this.key,
    required this.label,
    required this.group,
  });
}

const teamPermissionDefinitions = <PermissionDefinition>[
  PermissionDefinition(
    key: 'can_view_eggs',
    label: 'View Egg Logs',
    group: 'View',
  ),
  PermissionDefinition(
    key: 'can_view_feeding',
    label: 'View Feed Logs',
    group: 'View',
  ),
  PermissionDefinition(
    key: 'can_view_mortality',
    label: 'View Mortality Logs',
    group: 'View',
  ),
  PermissionDefinition(
    key: 'can_view_batches',
    label: 'View Batches',
    group: 'View',
  ),
  PermissionDefinition(
    key: 'can_view_inventory',
    label: 'View Inventory',
    group: 'View',
  ),
  PermissionDefinition(
    key: 'can_view_houses',
    label: 'View Houses',
    group: 'View',
  ),
  PermissionDefinition(
    key: 'can_view_finance',
    label: 'View Finances',
    group: 'View',
  ),
  PermissionDefinition(
    key: 'can_view_sales',
    label: 'View Sales',
    group: 'View',
  ),
  PermissionDefinition(key: 'can_view_team', label: 'View Team', group: 'View'),
  PermissionDefinition(
    key: 'can_edit_eggs',
    label: 'Edit Egg Logs',
    group: 'Edit',
  ),
  PermissionDefinition(
    key: 'can_edit_feeding',
    label: 'Edit Feed Logs',
    group: 'Edit',
  ),
  PermissionDefinition(
    key: 'can_edit_mortality',
    label: 'Edit Mortality Logs',
    group: 'Edit',
  ),
  PermissionDefinition(
    key: 'can_edit_batches',
    label: 'Manage Batches',
    group: 'Edit',
  ),
  PermissionDefinition(
    key: 'can_edit_inventory',
    label: 'Edit Inventory',
    group: 'Edit',
  ),
  PermissionDefinition(
    key: 'can_edit_houses',
    label: 'Edit Houses',
    group: 'Edit',
  ),
  PermissionDefinition(
    key: 'can_edit_finance',
    label: 'Edit Finances',
    group: 'Edit',
  ),
  PermissionDefinition(
    key: 'can_edit_sales',
    label: 'Edit Sales',
    group: 'Edit',
  ),
  PermissionDefinition(
    key: 'can_edit_team',
    label: 'Manage Team',
    group: 'Edit',
  ),
];

const _workerPreset = <String>{
  'can_view_eggs',
  'can_edit_eggs',
  'can_view_feeding',
  'can_edit_feeding',
  'can_view_mortality',
  'can_edit_mortality',
  'can_view_batches',
  'can_view_houses',
};

const _managerPreset = <String>{
  'can_view_eggs',
  'can_edit_eggs',
  'can_view_feeding',
  'can_edit_feeding',
  'can_view_mortality',
  'can_edit_mortality',
  'can_view_batches',
  'can_edit_batches',
  'can_view_inventory',
  'can_edit_inventory',
  'can_view_finance',
  'can_view_sales',
  'can_edit_sales',
  'can_view_team',
};

const _accountantPreset = <String>{
  'can_view_finance',
  'can_edit_finance',
  'can_view_sales',
  'can_edit_sales',
  'can_view_inventory',
  'can_view_batches',
};

String normalizeProvisioningRole(String role) {
  final cleaned = role.trim().toUpperCase();
  switch (cleaned) {
    case 'MANAGER':
    case 'ACCOUNTANT':
    case 'WORKER':
      return cleaned;
    default:
      return 'WORKER';
  }
}

Set<String> defaultPermissionsForRole(String role) {
  switch (normalizeProvisioningRole(role)) {
    case 'MANAGER':
      return {..._managerPreset};
    case 'ACCOUNTANT':
      return {..._accountantPreset};
    case 'WORKER':
    default:
      return {..._workerPreset};
  }
}

List<String> sortedPermissions(Iterable<String> permissions) {
  final validKeys = teamPermissionDefinitions.map((it) => it.key).toSet();
  return permissions.where(validKeys.contains).toSet().toList()..sort();
}

String encodePermissions(Iterable<String> permissions) =>
    jsonEncode(sortedPermissions(permissions));

List<String> decodePermissions(dynamic value) {
  if (value == null) return const [];
  if (value is List) return sortedPermissions(value.map((it) => it.toString()));
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return const [];
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is List) {
        return sortedPermissions(decoded.map((it) => it.toString()));
      }
    } catch (_) {
      return sortedPermissions(
        trimmed
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((it) => it.trim())
            .where((it) => it.isNotEmpty),
      );
    }
  }
  return const [];
}

String profileDisplayName(Map<String, dynamic> profile) {
  final firstName = (profile['firstName'] ?? profile['first_name'] ?? '')
      .toString()
      .trim();
  final lastName = (profile['lastName'] ?? profile['last_name'] ?? '')
      .toString()
      .trim();
  final fullName = [firstName, lastName].where((it) => it.isNotEmpty).join(' ');
  if (fullName.isNotEmpty) return fullName;
  final phone = (profile['phoneNumber'] ?? profile['phone_number'] ?? '')
      .toString()
      .trim();
  return 'Pending Activation ($phone)';
}

class TeamProvisioningRequest {
  final String profileId;
  final String farmId;
  final String phoneNumber;
  final String role;
  final List<String> permissions;
  final bool permissionsCustomized;

  const TeamProvisioningRequest({
    required this.profileId,
    required this.farmId,
    required this.phoneNumber,
    required this.role,
    required this.permissions,
    required this.permissionsCustomized,
  });

  Map<String, dynamic> toJson() => {
    'profileId': profileId,
    'farmId': farmId,
    'phoneNumber': phoneNumber,
    'role': normalizeProvisioningRole(role),
    'permissions': sortedPermissions(permissions),
    'permissionsCustomized': permissionsCustomized,
    'placeholderPassword': workerPlaceholderPassword,
  };
}

class TeamProvisioningService {
  final SupabaseClient _supabase;

  TeamProvisioningService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<Map<String, dynamic>> provisionTeamMember(
    TeamProvisioningRequest request,
  ) async {
    final response = await _supabase.functions.invoke(
      'provision-team-member',
      body: request.toJson(),
    );

    final data = response.data;
    if (data is Map) {
      final profile = data['profile'];
      if (profile is Map) return Map<String, dynamic>.from(profile);
      return Map<String, dynamic>.from(data);
    }

    throw Exception('Provisioning backend returned an unexpected response.');
  }
}
