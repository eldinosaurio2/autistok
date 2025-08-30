import 'dart:convert';
import 'package:autistock/services/storage_service.dart';
import 'package:autistock/services/web_storage.dart' as web_storage;

StorageService getStorageService() => StorageServiceWeb();

class StorageServiceWeb implements StorageService {
  @override
  Future<void> init() async {
    // No es necesaria una inicialización explícita para localStorage
  }

  @override
  String? getValue(String key) {
    return web_storage.getValue(key);
  }

  @override
  Future<void> saveValue(String key, String value) async {
    web_storage.saveValue(key, value);
  }

  @override
  bool? getBool(String key) {
    final value = web_storage.getValue(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    web_storage.saveValue(key, value.toString());
  }

  @override
  double? getDouble(String key) {
    final value = web_storage.getValue(key);
    if (value == null) return null;
    return double.tryParse(value);
  }

  @override
  Future<void> saveDouble(String key, double value) async {
    web_storage.saveValue(key, value.toString());
  }

  @override
  List<String>? getStringList(String key) {
    final value = web_storage.getValue(key);
    if (value == null) return null;
    try {
      return List<String>.from(jsonDecode(value));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveStringList(String key, List<String> value) async {
    web_storage.saveValue(key, jsonEncode(value));
  }

  @override
  Future<void> remove(String key) async {
    web_storage.remove(key);
  }
}
