import 'dart:convert';
import 'package:autistock/models/activity.dart';
import 'package:autistock/models/emergency_contact.dart';
import 'package:autistock/models/mood_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  Future<void> saveMood(MoodEntry mood) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = mood.date.toIso8601String().substring(0, 10);
    final moodsJson = prefs.getStringList('moods_$dateString') ?? [];
    moodsJson.add(jsonEncode(mood.toJson()));
    await prefs.setStringList('moods_$dateString', moodsJson);
  }

  Future<List<MoodEntry>> getMoodsForDay(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = date.toIso8601String().substring(0, 10);
    final moodsJson = prefs.getStringList('moods_$dateString');
    if (moodsJson == null) {
      return [];
    }
    return moodsJson
        .map((json) => MoodEntry.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<List<Activity>> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    String? json = prefs.getString('activities');
    if (json == null) {
      return [];
    }
    List<dynamic> jsonList = jsonDecode(json);
    return jsonList.map((j) => Activity.fromJson(j)).toList();
  }

  Future<List<MoodEntry>> loadMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    String? json = prefs.getString('mood_entries');
    if (json == null) {
      return [];
    }
    List<dynamic> jsonList = jsonDecode(json);
    return jsonList.map((j) => MoodEntry.fromJson(j)).toList();
  }

  Future<List<MoodEntry>> getAllMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final allMoods = <MoodEntry>[];

    for (final key in keys) {
      if (key.startsWith('moods_')) {
        final moodsJson = prefs.getStringList(key);
        if (moodsJson != null) {
          final moods = moodsJson
              .map((json) => MoodEntry.fromJson(jsonDecode(json)))
              .toList();
          allMoods.addAll(moods);
        }
      }
    }
    allMoods.sort((a, b) => a.date.compareTo(b.date));
    return allMoods;
  }

  Future<List<EmergencyContact>> loadEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    // Migration from single contact to list
    if (prefs.containsKey('emergency_contact_name') &&
        prefs.containsKey('emergency_contact_phone')) {
      final name = prefs.getString('emergency_contact_name');
      final phone = prefs.getString('emergency_contact_phone');
      if (name != null && phone != null) {
        final contact = EmergencyContact(name: name, phone: phone);
        await saveEmergencyContacts([contact]);
        await prefs.remove('emergency_contact_name');
        await prefs.remove('emergency_contact_phone');
        return [contact];
      }
    }

    final dynamic contactsData = prefs.get('emergency_contacts');

    if (contactsData == null) {
      return [];
    }

    if (contactsData is List) {
      try {
        final contactsJson = contactsData.cast<String>().toList();
        return contactsJson
            .map((jsonString) =>
                EmergencyContact.fromJson(jsonDecode(jsonString)))
            .toList();
      } catch (e) {
        // The list contained non-string elements. Treat as corrupt.
        await prefs.remove('emergency_contacts');
        return [];
      }
    } else {
      // Data is not a list. Treat as corrupt.
      await prefs.remove('emergency_contacts');
      return [];
    }
  }

  Future<void> saveEmergencyContacts(List<EmergencyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson =
        contacts.map((contact) => jsonEncode(contact.toJson())).toList();
    await prefs.setStringList('emergency_contacts', contactsJson);
  }

  Future<void> saveActivitiesForDay(
      DateTime day, List<Activity> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = day.toIso8601String().substring(0, 10);
    // Fix: Save as a standard list of JSON objects.
    final activitiesJson =
        activities.map((activity) => activity.toJson()).toList();
    await prefs.setString('activities_$dateString', jsonEncode(activitiesJson));
  }

  Future<List<Activity>> getActivitiesForDay(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = day.toIso8601String().substring(0, 10);
    final activitiesJson = prefs.getString('activities_$dateString');
    if (activitiesJson == null) {
      return [];
    }
    final activitiesList = jsonDecode(activitiesJson) as List;
    if (activitiesList.isEmpty) {
      return [];
    }

    // Fix: Handle both old and new data formats for robustness.
    if (activitiesList.first is String) {
      // Old format: List of JSON strings
      return activitiesList
          .map((json) => Activity.fromJson(jsonDecode(json)))
          .toList();
    } else {
      // New format: List of Maps
      return activitiesList.map((json) => Activity.fromJson(json)).toList();
    }
  }

  Future<List<DateTime>> getDatesWithActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final dates = <DateTime>[];
    for (final key in keys) {
      if (key.startsWith('activities_')) {
        final dateString = key.substring('activities_'.length);
        dates.add(DateTime.parse(dateString));
      }
    }
    return dates;
  }

  Future<List<Activity>> getAllActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final allActivities = <Activity>[];

    for (final key in keys) {
      if (key.startsWith('activities_')) {
        final activitiesJson = prefs.getString(key);
        if (activitiesJson != null) {
          try {
            final activitiesList = jsonDecode(activitiesJson) as List;
            if (activitiesList.isEmpty) {
              continue;
            }

            // Fix: Handle inconsistent data format to prevent crashes.
            if (activitiesList.first is String) {
              // Old format: List of JSON strings
              final activities = activitiesList
                  .map((jsonString) =>
                      Activity.fromJson(jsonDecode(jsonString as String)))
                  .toList();
              allActivities.addAll(activities);
            } else if (activitiesList.first is Map) {
              // New format: List of Maps
              final activities = activitiesList
                  .map((jsonMap) =>
                      Activity.fromJson(jsonMap as Map<String, dynamic>))
                  .toList();
              allActivities.addAll(activities);
            }
          } catch (e) {
            print('Could not parse activities for key $key: $e');
          }
        }
      }
    }
    allActivities.sort((a, b) => a.date.compareTo(b.date));
    return allActivities;
  }

  Future<void> saveProfileName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', name);
  }

  Future<String> getProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_name') ?? '';
  }

  Future<void> saveBirthYear(String year) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('birth_year', year);
  }

  Future<String> getBirthYear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('birth_year') ?? '';
  }

  Future<void> saveGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gender', gender);
  }

  Future<String?> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gender');
  }

  Future<void> saveOtherGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('other_gender', gender);
  }

  Future<String> getOtherGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('other_gender') ?? '';
  }

  Future<void> setProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_path');
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<bool> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> saveTextScaleFactor(double scaleFactor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScaleFactor', scaleFactor);
  }

  Future<double> loadTextScaleFactor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('textScaleFactor') ?? 1.0;
  }

  Future<void> saveNotificationSettings(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_settings', enabled);
  }

  Future<bool> loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification_settings') ?? false;
  }

  Future<void> saveNotificationTimes(List<String> times) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notification_times', times);
  }

  Future<List<String>> loadNotificationTimes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('notification_times') ?? [];
  }

  Future<void> saveNotificationTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', hour);
    await prefs.setInt('notification_minute', minute);
  }

  Future<Map<String, int?>> loadNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    int? hour = prefs.getInt('notification_hour');
    int? minute = prefs.getInt('notification_minute');
    return {'hour': hour, 'minute': minute};
  }

  Future<void> saveActivities(List<Activity> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson =
        activities.map((activity) => activity.toJson()).toList();
    await prefs.setString('activities', jsonEncode(activitiesJson));
  }

  Future<void> saveUnlockedRewardIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('unlocked_reward_ids', ids);
  }

  Future<void> saveMoodEntries(List<MoodEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    String json = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString('mood_entries', json);
  }

  Future<List<String>> loadUnlockedRewardIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('unlocked_reward_ids') ?? [];
  }

  Future<void> saveButtonFrequencies(Map<String, int> frequencies) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(frequencies);
    await prefs.setString('button_frequencies', jsonString);
  }

  Future<Map<String, int>> loadButtonFrequencies() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('button_frequencies');
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return jsonMap.map((key, value) => MapEntry(key, value as int));
    }
    return {};
  }
}
