import 'package:autistock/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

StorageService getStorageService() => StorageServiceMobile();

class StorageServiceMobile implements StorageService {
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  String? getValue(String key) {
    return _prefs.getString(key);
  }

  @override
  Future<void> saveValue(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  @override
  Future<void> saveDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  @override
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  @override
  Future<void> saveStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
