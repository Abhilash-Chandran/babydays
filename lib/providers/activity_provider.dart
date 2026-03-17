import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../services/activity_storage_service.dart';

/// ChangeNotifier holding the current day's activities.
class ActivityProvider extends ChangeNotifier {
  ActivityStorageService _storage;
  final Uuid _uuid = const Uuid();

  late DateTime _selectedDate;
  List<Activity> _activities = [];
  bool _isLoading = false;

  ActivityProvider(this._storage) : _selectedDate = _dateOnly(DateTime.now());

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Swap the underlying storage (e.g. from local to Firestore).
  Future<void> swapStorage(ActivityStorageService newStorage) async {
    _storage = newStorage;
    await loadActivities();
  }

  ActivityStorageService get storage => _storage;
  DateTime get selectedDate => _selectedDate;
  List<Activity> get activities => List.unmodifiable(_activities);
  bool get isLoading => _isLoading;

  /// Change the selected date and reload.
  Future<void> selectDate(DateTime date) async {
    _selectedDate = _dateOnly(date);
    await loadActivities();
  }

  /// Load activities for the selected date.
  Future<void> loadActivities() async {
    _isLoading = true;
    notifyListeners();
    try {
      _activities = await _storage.getActivitiesForDate(_selectedDate);
    } catch (e) {
      debugPrint('Failed to load activities: $e');
      _activities = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Add a new activity and reload.
  Future<void> addActivity({
    required ActivityType type,
    required DateTime startTime,
    DateTime? endTime,
    String? notes,
    List<BreastFeedingDetail>? breastFeedingDetails,
    double? formulaAmountMl,
    DiaperType? diaperType,
  }) async {
    final activity = Activity(
      id: _uuid.v4(),
      type: type,
      date: _dateOnly(startTime),
      startTime: startTime,
      endTime: endTime,
      notes: notes,
      breastFeedingDetails: breastFeedingDetails,
      formulaAmountMl: formulaAmountMl,
      diaperType: diaperType,
    );
    await _storage.addActivity(activity);
    // If the saved activity belongs to the currently viewed date, reload.
    if (_dateOnly(startTime) == _selectedDate) {
      await loadActivities();
    }
  }

  /// Update an existing activity.
  Future<void> updateActivity(Activity activity) async {
    await _storage.updateActivity(activity);
    if (_dateOnly(activity.date) == _selectedDate) {
      await loadActivities();
    }
  }

  /// Delete an activity.
  Future<void> deleteActivity(Activity activity) async {
    await _storage.deleteActivity(activity.id, activity.date);
    if (_dateOnly(activity.date) == _selectedDate) {
      await loadActivities();
    }
  }

  String generateId() => _uuid.v4();
}
