import 'package:autistock/services/storage_service_stub.dart'
    if (dart.library.io) 'package:autistock/services/storage_service_mobile.dart'
    if (dart.library.html) 'package:autistock/services/storage_service_web.dart';

abstract class StorageService {
  Future<void> init();
  String? getValue(String key);
  Future<void> saveValue(String key, String value);
  bool? getBool(String key);
  Future<void> saveBool(String key, bool value);
  double? getDouble(String key);
  Future<void> saveDouble(String key, double value);
  List<String>? getStringList(String key);
  Future<void> saveStringList(String key, List<String> value);
  Future<void> remove(String key);

  factory StorageService() => getStorageService();
}

void saveValue(String key, String value) {
  // No-op for mobile, as SharedPreferences is used directly.
}

String? getValue(String key) {
  // No-op for mobile.
  return null;
}

void saveBool(String key, bool value) {
  // No-op for mobile.
}

bool? getBool(String key) {
  // No-op for mobile.
  return null;
}

void saveDouble(String key, double value) {
  // No-op for mobile.
}

double? getDouble(String key) {
  // No-op for mobile.
  return null;
}
