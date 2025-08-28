import 'package:autistock/models/mood_entry.dart';
import 'package:autistock/models/reward.dart';
import 'package:flutter/material.dart';

class RewardService extends ChangeNotifier {
  final dynamic dataService; // Add this field, use the correct type if known
  final List<Reward> _rewards = [
    Reward(
      id: 'first_entry',
      name: '🥉 Comenzaste tu viaje',
      description: 'Registra tu primer estado de ánimo.',
      iconPath: '', // Placeholder
      unlockCondition: (entries) => entries.isNotEmpty,
    ),
    Reward(
      id: 'seven_days_streak',
      name: '🥈 Constancia semanal',
      description: 'Registra tu estado de ánimo por 7 días seguidos.',
      iconPath: '', // Placeholder
      unlockCondition: (entries) => _hasConsecutiveDays(entries, 7),
    ),
    Reward(
      id: 'thirty_days_streak',
      name: '🥇 Maestro de la rutina',
      description: 'Registra tu estado de ánimo por 30 días seguidos.',
      iconPath: '', // Placeholder
      unlockCondition: (entries) => _hasConsecutiveDays(entries, 30),
    ),
    Reward(
      id: 'full_day',
      name: '🌞🌙 Día completo',
      description:
          'Registra tu ánimo en la mañana y en la tarde/noche del mismo día.',
      iconPath: '', // Placeholder
      unlockCondition: (entries) => _hasMorningAndAfternoonEntry(entries),
    ),
  ];
  List<String> _unlockedRewardIds = [];

  List<Reward> get rewards => _rewards;

  RewardService(this.dataService) {
    _loadUnlockedRewards();
  }

  void _loadUnlockedRewards() async {
    _unlockedRewardIds = await dataService.loadUnlockedRewardIds();
    for (var reward in _rewards) {
      if (_unlockedRewardIds.contains(reward.id)) {
        reward.unlocked = true;
      }
    }
    notifyListeners();
  }

  void checkAndUnlockRewards(List<MoodEntry> allEntries) async {
    bool changed = false;
    for (var reward in _rewards) {
      if (!reward.unlocked && reward.unlockCondition(allEntries)) {
        reward.unlocked = true;
        _unlockedRewardIds.add(reward.id);
        changed = true;
      }
    }
    if (changed) {
      await dataService.saveUnlockedRewardIds(_unlockedRewardIds);
      notifyListeners();
    }
  }

  static bool _hasMorningAndAfternoonEntry(List<MoodEntry> entries) {
    // Group entries by day
    var entriesByDay = <DateTime, List<MoodEntry>>{};
    for (var entry in entries) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      entriesByDay.putIfAbsent(day, () => []).add(entry);
    }

    // Check if any day has both morning and afternoon entries
    for (var dayEntries in entriesByDay.values) {
      bool hasMorning = dayEntries.any((e) => e.date.hour < 12);
      bool hasAfternoon = dayEntries.any((e) => e.date.hour >= 12);
      if (hasMorning && hasAfternoon) {
        return true;
      }
    }
    return false;
  }

  static bool _hasConsecutiveDays(List<MoodEntry> entries, int days) {
    if (entries.length < days) {
      return false;
    }
    // Use a Set to get unique days, then convert to a list and sort.
    final dates = entries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList();
    dates.sort();

    if (dates.length < days) {
      return false;
    }

    int consecutiveCount = 1;
    for (int i = 1; i < dates.length; i++) {
      // Check if the difference is exactly one day
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        consecutiveCount++;
        if (consecutiveCount >= days) {
          return true;
        }
      } else if (dates[i].difference(dates[i - 1]).inDays > 1) {
        // Reset if the gap is more than one day
        consecutiveCount = 1;
      }
    }
    return false;
  }
}
