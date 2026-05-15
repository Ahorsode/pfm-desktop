import 'package:shared_preferences/shared_preferences.dart';

class FarmUtils {
  static Future<int?> getBoundFarmId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bound_farm_id');
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<bool> canViewFinancials() async {
    final role = await getUserRole();
    return role == 'OWNER' || role == 'ACCOUNTANT' || role == 'MANAGER';
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}
