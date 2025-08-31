import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:autistock/models/mood_entry.dart';
import 'package:autistock/models/activity.dart';
import 'package:autistock/models/emergency_contact.dart';
import 'package:autistock/models/energy_entry.dart';
import 'package:autistock/models/reward.dart';

class DataService {
  static const String _energyHistoryKey = 'energy_history';

  Future<SharedPreferences> _getPrefs() async {
    return SharedPreferences.getInstance();
  }

  Future<void> saveMood(MoodEntry mood) async {
    final prefs = await _getPrefs();
    final dateString = mood.date.toIso8601String().substring(0, 10);
    final moodsJson = prefs.getStringList('moods_$dateString') ?? [];
    moodsJson.add(jsonEncode(mood.toJson()));
    await prefs.setStringList('moods_$dateString', moodsJson);
  }

  Future<List<MoodEntry>> getMoodsForDay(DateTime date) async {
    final prefs = await _getPrefs();
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
    final prefs = await _getPrefs();
    String? json = prefs.getString('activities');
    if (json == null) {
      return [];
    }
    List<dynamic> jsonList = jsonDecode(json);
    return jsonList.map((j) => Activity.fromJson(j)).toList();
  }

  Future<List<MoodEntry>> loadMoodEntries() async {
    final prefs = await _getPrefs();
    String? json = prefs.getString('mood_entries');
    if (json == null) {
      return [];
    }
    List<dynamic> jsonList = jsonDecode(json);
    return jsonList.map((j) => MoodEntry.fromJson(j)).toList();
  }

  Future<List<MoodEntry>> getMoodHistory() async {
    final prefs = await _getPrefs();
    String? json = prefs.getString('mood_entries');
    if (json == null) {
      return [];
    }
    List<dynamic> jsonList = jsonDecode(json);
    return jsonList.map((j) => MoodEntry.fromJson(j)).toList();
  }

  Future<void> addMoodEntry(MoodEntry entry) async {
    final entries = await getMoodHistory();
    entries.add(entry);
    await saveMoodEntries(entries);
  }

  Future<List<MoodEntry>> getAllMoods() async {
    // This functionality depends on being able to list all keys,
    // which is not currently part of the StorageService interface.
    // This will be addressed in a future update.
    return [];
  }

  Future<List<EmergencyContact>> loadEmergencyContacts() async {
    final prefs = await _getPrefs();
    final contactsJson = prefs.getStringList('emergency_contacts');
    if (contactsJson == null) {
      return [];
    }
    try {
      return contactsJson
          .map(
              (jsonString) => EmergencyContact.fromJson(jsonDecode(jsonString)))
          .toList();
    } catch (e) {
      await prefs.remove('emergency_contacts');
      return [];
    }
  }

  Future<void> saveEmergencyContacts(List<EmergencyContact> contacts) async {
    final prefs = await _getPrefs();
    final contactsJson =
        contacts.map((contact) => jsonEncode(contact.toJson())).toList();
    await prefs.setStringList('emergency_contacts', contactsJson);
  }

  Future<void> saveActivitiesForDay(
      DateTime day, List<Activity> activities) async {
    final prefs = await _getPrefs();
    final dateString = day.toIso8601String().substring(0, 10);
    final activitiesJson =
        activities.map((activity) => activity.toJson()).toList();
    await prefs.setString('activities_$dateString', jsonEncode(activitiesJson));
  }

  Future<List<Activity>> getActivitiesForDayV3(DateTime day) async {
    final activities = await loadActivities();
    return activities
        .where((activity) =>
            activity.date.year == day.year &&
            activity.date.month == day.month &&
            activity.date.day == day.day)
        .toList();
  }

  Future<List<Activity>> fetchAllActivities() async {
    return await loadActivities();
  }

  Future<void> saveActivitiesForDayV2Alt(
      DateTime day, List<Activity> activities) async {
    final allActivities = await loadActivities();
    final dateString = day.toIso8601String().substring(0, 10);
    final activitiesJson =
        activities.map((activity) => activity.toJson()).toList();
    final prefs = await _getPrefs();
    await prefs.setString('activities_$dateString', jsonEncode(activitiesJson));
  }

  Future<List<DateTime>> getDatesWithActivities() async {
    final activities = await loadActivities();
    return activities.map((activity) => activity.date).toSet().toList();
  }

  Future<List<Activity>> fetchAllActivitiesList() async {
    return await loadActivities();
  }

  Future<void> saveActivitiesForDayMerged(
      DateTime day, List<Activity> activities) async {
    List<Activity> allActivities = await loadActivities();
    allActivities.removeWhere((activity) =>
        activity.date.year == day.year &&
        activity.date.month == day.month &&
        activity.date.day == day.day);
    allActivities.addAll(activities);
    await saveActivities(allActivities);
  }

  Future<List<Activity>> getActivitiesForDay(DateTime day) async {
    final activities = await loadActivities();
    return activities
        .where((activity) =>
            activity.date.year == day.year &&
            activity.date.month == day.month &&
            activity.date.day == day.day)
        .toList();
  }

  Future<List<Activity>> getAllActivities() async {
    return await loadActivities();
  }

  Future<void> saveActivitiesForDayV2(
      DateTime day, List<Activity> activities) async {
    final allActivities = await loadActivities();
    final dateString = day.toIso8601String().substring(0, 10);
    final activitiesJson =
        activities.map((activity) => activity.toJson()).toList();
    final prefs = await _getPrefs();
    await prefs.setString('activities_$dateString', jsonEncode(activitiesJson));
  }

  Future<List<DateTime>> getDatesWithActivitiesFromKeys() async {
    // This functionality depends on being able to list all keys.
    return [];
  }

  Future<List<Activity>> getAllActivitiesFromKeys() async {
    // This functionality depends on being able to list all keys.
    return [];
  }

  Future<void> saveProfileName(String name) async {
    final prefs = await _getPrefs();
    await prefs.setString('profile_name', name);
  }

  Future<String> getProfileName() async {
    final prefs = await _getPrefs();
    return prefs.getString('profile_name') ?? '';
  }

  Future<void> saveBirthYear(String year) async {
    final prefs = await _getPrefs();
    await prefs.setString('birth_year', year);
  }

  Future<String> getBirthYear() async {
    final prefs = await _getPrefs();
    return prefs.getString('birth_year') ?? '';
  }

  Future<void> saveGender(String gender) async {
    final prefs = await _getPrefs();
    await prefs.setString('gender', gender);
  }

  Future<String?> getGender() async {
    final prefs = await _getPrefs();
    return prefs.getString('gender');
  }

  Future<void> saveOtherGender(String gender) async {
    final prefs = await _getPrefs();
    await prefs.setString('other_gender', gender);
  }

  Future<String> getOtherGender() async {
    final prefs = await _getPrefs();
    return prefs.getString('other_gender') ?? '';
  }

  Future<void> setProfileImagePath(String path) async {
    final prefs = await _getPrefs();
    await prefs.setString('profile_image_path', path);
  }

  Future<String?> getProfileImagePath() async {
    final prefs = await _getPrefs();
    return prefs.getString('profile_image_path');
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await _getPrefs();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<bool> loadThemeMode() async {
    final prefs = await _getPrefs();
    return prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await _getPrefs();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<bool> loadTheme() async {
    final prefs = await _getPrefs();
    return prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> saveTextScaleFactor(double scaleFactor) async {
    final prefs = await _getPrefs();
    await prefs.setDouble('textScaleFactor', scaleFactor);
  }

  Future<double> loadTextScaleFactor() async {
    final prefs = await _getPrefs();
    return prefs.getDouble('textScaleFactor') ?? 1.0;
  }

  Future<void> saveNotificationSettings(String type, bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool('notifications_enabled_$type', enabled);
  }

  Future<bool> loadNotificationSettings(String type) async {
    final prefs = await _getPrefs();
    // Devuelve true por defecto para las notificaciones de actividades y recompensas
    if (type == 'activity' || type == 'reward') {
      return prefs.getBool('notifications_enabled_$type') ?? true;
    }
    return prefs.getBool('notifications_enabled_$type') ?? false;
  }

  Future<void> saveGlobalNotificationSetting(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool('global_notifications_enabled', enabled);
  }

  Future<bool> loadGlobalNotificationSetting() async {
    final prefs = await _getPrefs();
    return prefs.getBool('global_notifications_enabled') ?? true;
  }

  Future<void> saveNotificationTimes(List<String> times) async {
    final prefs = await _getPrefs();
    await prefs.setStringList('notification_times', times);
  }

  Future<List<String>> loadNotificationTimes() async {
    final prefs = await _getPrefs();
    return prefs.getStringList('notification_times') ?? [];
  }

  Future<void> saveNotificationTime(int hour, int minute) async {
    final prefs = await _getPrefs();
    await prefs.setInt('notification_hour', hour);
    await prefs.setInt('notification_minute', minute);
  }

  Future<Map<String, int?>> loadNotificationTime() async {
    final prefs = await _getPrefs();
    return {
      'hour': prefs.getInt('notification_hour'),
      'minute': prefs.getInt('notification_minute')
    };
  }

  Future<void> saveActivities(List<Activity> activities) async {
    final prefs = await _getPrefs();
    final activitiesJson =
        activities.map((activity) => activity.toJson()).toList();
    await prefs.setString('activities', jsonEncode(activitiesJson));
  }

  Future<void> saveUnlockedRewardIdsV2(List<String> ids) async {
    final prefs = await _getPrefs();
    await prefs.setStringList('unlocked_reward_ids', ids);
  }

  Future<void> saveMoodEntriesV2(List<MoodEntry> entries) async {
    final prefs = await _getPrefs();
    String json = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString('mood_entries', json);
  }

  Future<List<String>> loadUnlockedRewardIdsV2() async {
    final prefs = await _getPrefs();
    return prefs.getStringList('unlocked_reward_ids') ?? [];
  }

  Future<void> saveButtonFrequenciesV2(Map<String, int> frequencies) async {
    final prefs = await _getPrefs();
    final jsonString = jsonEncode(frequencies);
    await prefs.setString('button_frequencies', jsonString);
  }

  Future<Map<String, int>> loadButtonFrequenciesFromPrefs() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString('button_frequencies');
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return jsonMap.map((key, value) => MapEntry(key, value as int));
    }
    return {};
  }

  Future<void> addEnergyEntry(EnergyEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getEnergyHistory();
    history.add(entry);
    final jsonList = history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_energyHistoryKey, jsonList);
  }

  Future<List<EnergyEntry>> getEnergyHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_energyHistoryKey) ?? [];
    return jsonList
        .map((e) => EnergyEntry.fromJson(jsonDecode(e)))
        .toList()
        .cast<EnergyEntry>();
  }

  Future<void> saveRewards(List<Reward> rewards) async {
    final prefs = await _getPrefs();
    final rewardsJson = rewards.map((reward) => reward.toJson()).toList();
    await prefs.setString('rewards', jsonEncode(rewardsJson));
  }

  Future<void> saveUnlockedRewardIds(List<String> ids) async {
    final prefs = await _getPrefs();
    await prefs.setStringList('unlocked_reward_ids', ids);
  }

  Future<void> saveMoodEntries(List<MoodEntry> entries) async {
    final prefs = await _getPrefs();
    String json = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString('mood_entries', json);
  }

  Future<List<String>> loadUnlockedRewardIds() async {
    final prefs = await _getPrefs();
    return prefs.getStringList('unlocked_reward_ids') ?? [];
  }

  Future<void> saveButtonFrequencies(Map<String, int> frequencies) async {
    final prefs = await _getPrefs();
    final jsonString = jsonEncode(frequencies);
    await prefs.setString('button_frequencies', jsonString);
  }

  Future<void> saveLightSensitivity(double value) async {
    final prefs = await _getPrefs();
    await prefs.setDouble('light_sensitivity', value);
  }

  Future<double> loadLightSensitivity() async {
    final prefs = await _getPrefs();
    return prefs.getDouble('light_sensitivity') ?? 5.0;
  }

  Future<void> saveSoundSensitivity(double value) async {
    final prefs = await _getPrefs();
    await prefs.setDouble('sound_sensitivity', value);
  }

  Future<double> loadSoundSensitivity() async {
    final prefs = await _getPrefs();
    return prefs.getDouble('sound_sensitivity') ?? 5.0;
  }

  Future<Map<String, int>> loadButtonFrequencies() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString('button_frequencies');
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return jsonMap.map((key, value) => MapEntry(key, value as int));
    }
    return {};
  }
}
