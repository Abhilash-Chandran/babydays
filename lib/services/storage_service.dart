import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';

/// Provides persistence for baby activity data using shared_preferences,
/// which maps to localStorage on web and SharedPreferences on mobile.
class StorageService {
  static const String _activitiesKeyPrefix = 'activities_';
  static const String _allDatesKey = 'tracked_dates';

  late final SharedPreferences _prefs;

  /// Must be called once before using any other method.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Storage key for a given date.
  String _keyForDate(DateTime date) {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$_activitiesKeyPrefix$dateStr';
  }

  /// Get all activities for a specific date, sorted by start time.
  Future<List<Activity>> getActivitiesForDate(DateTime date) async {
    final key = _keyForDate(date);
    final jsonString = _prefs.getString(key);
    if (jsonString == null || jsonString.isEmpty) return [];
    final activities = Activity.decodeList(jsonString);
    activities.sort((a, b) => a.startTime.compareTo(b.startTime));
    return activities;
  }

  /// Save a new activity.
  Future<void> addActivity(Activity activity) async {
    final activities = await getActivitiesForDate(activity.date);
    activities.add(activity);
    await _saveActivitiesForDate(activity.date, activities);
    await _trackDate(activity.date);
  }

  /// Update an existing activity (matched by id).
  Future<void> updateActivity(Activity activity) async {
    final activities = await getActivitiesForDate(activity.date);
    final index = activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      activities[index] = activity;
      await _saveActivitiesForDate(activity.date, activities);
    }
  }

  /// Delete an activity by id for a given date.
  Future<void> deleteActivity(String id, DateTime date) async {
    final activities = await getActivitiesForDate(date);
    activities.removeWhere((a) => a.id == id);
    await _saveActivitiesForDate(date, activities);
  }

  /// Get a list of all dates that have tracked activities.
  List<DateTime> getTrackedDates() {
    final dateStrings = _prefs.getStringList(_allDatesKey) ?? [];
    return dateStrings.map((s) {
      final parts = s.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }).toList()..sort();
  }

  /// Persist the list of activities for a date.
  Future<void> _saveActivitiesForDate(
    DateTime date,
    List<Activity> activities,
  ) async {
    final key = _keyForDate(date);
    if (activities.isEmpty) {
      await _prefs.remove(key);
      await _untrackDate(date);
    } else {
      await _prefs.setString(key, Activity.encodeList(activities));
    }
  }

  /// Record that a date has data.
  Future<void> _trackDate(DateTime date) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final dates = _prefs.getStringList(_allDatesKey) ?? [];
    if (!dates.contains(dateStr)) {
      dates.add(dateStr);
      await _prefs.setStringList(_allDatesKey, dates);
    }
  }

  /// Remove a date from the tracked-dates index.
  Future<void> _untrackDate(DateTime date) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final dates = _prefs.getStringList(_allDatesKey) ?? [];
    dates.remove(dateStr);
    await _prefs.setStringList(_allDatesKey, dates);
  }

  /// Clear all stored data (useful for testing / reset).
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
