// lib/services/web_storage.dart
import 'dart:html' as html;

void saveValue(String key, String value) {
  html.window.localStorage[key] = value;
}

String? getValue(String key) {
  return html.window.localStorage[key];
}

void saveBool(String key, bool value) {
  html.window.localStorage[key] = value.toString();
}

bool? getBool(String key) {
  return html.window.localStorage[key] == 'true';
}

void saveDouble(String key, double value) {
  html.window.localStorage[key] = value.toString();
}

double? getDouble(String key) {
  final value = html.window.localStorage[key];
  return value != null ? double.tryParse(value) : null;
}

void remove(String key) {
  html.window.localStorage.remove(key);
}
