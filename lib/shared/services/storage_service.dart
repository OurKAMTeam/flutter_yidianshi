import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  String getString(String key) => _prefs.getString(key) ?? '';
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  
  bool getBool(String key) => _prefs.getBool(key) ?? false;
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  
  int getInt(String key) => _prefs.getInt(key) ?? 0;
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  
  double getDouble(String key) => _prefs.getDouble(key) ?? 0.0;
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);
  
  List<String> getStringList(String key) => _prefs.getStringList(key) ?? [];
  Future<bool> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);
  
  bool containsKey(String key) => _prefs.containsKey(key);
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}
