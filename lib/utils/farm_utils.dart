import 'package:shared_preferences/shared_preferences.dart';

class FarmUtils {
  static Future<int?> getBoundFarmId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bound_farm_id');
  }
}
