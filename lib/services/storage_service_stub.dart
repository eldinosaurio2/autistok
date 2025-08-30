import 'package:autistock/services/storage_service.dart';

StorageService getStorageService() => throw UnsupportedError(
    'Cannot create a StorageService without dart:html or dart:io.');

class StorageServiceStub implements StorageService {
  @override
  Future<void> init() async {}

  @override
  String? getValue(String key) => null;

  @override
  Future<void> saveValue(String key, String value) async {}

  @override
  bool? getBool(String key) => null;

  @override
  Future<void> saveBool(String key, bool value) async {}

  @override
  double? getDouble(String key) => null;

  @override
  Future<void> saveDouble(String key, double value) async {}

  @override
  List<String>? getStringList(String key) => null;

  @override
  Future<void> saveStringList(String key, List<String> value) async {}

  @override
  Future<void> remove(String key) async {}
}
