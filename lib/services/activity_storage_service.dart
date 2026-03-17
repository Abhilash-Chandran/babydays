import '../models/activity.dart';

/// Abstract interface for activity storage backends.
abstract class ActivityStorageService {
  Future<List<Activity>> getActivitiesForDate(DateTime date);
  Future<void> addActivity(Activity activity);
  Future<void> updateActivity(Activity activity);
  Future<void> deleteActivity(String id, DateTime date);
  Future<List<DateTime>> getTrackedDates();
}
