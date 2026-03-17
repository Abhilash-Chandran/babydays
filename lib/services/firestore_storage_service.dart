import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/activity.dart';
import 'activity_storage_service.dart';

/// Firestore-backed storage for activity data, scoped per user.
class FirestoreStorageService implements ActivityStorageService {
  final FirebaseFirestore _firestore;
  final String userId;

  FirestoreStorageService({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _timeout = Duration(seconds: 10);

  /// Reference to this user's activities collection.
  CollectionReference<Map<String, dynamic>> get _activitiesRef =>
      _firestore.collection('users').doc(userId).collection('activities');

  /// Quick connectivity check — tries a small read with a short timeout.
  Future<bool> isAvailable() async {
    try {
      await _activitiesRef.limit(1).get().timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      debugPrint('Firestore not available: $e');
      return false;
    }
  }

  /// Date-only string: yyyy-MM-dd.
  String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Get all activities for a specific date, sorted by start time.
  @override
  Future<List<Activity>> getActivitiesForDate(DateTime date) async {
    final snap = await _activitiesRef
        .where('date', isEqualTo: _dateStr(date))
        .get()
        .timeout(_timeout);
    final activities = snap.docs.map((doc) => Activity.fromJson(doc.data())).toList();
    activities.sort((a, b) => a.startTime.compareTo(b.startTime));
    return activities;
  }

  /// Save a new activity.
  @override
  Future<void> addActivity(Activity activity) async {
    await _activitiesRef.doc(activity.id).set(activity.toJson()).timeout(_timeout);
  }

  /// Update an existing activity (matched by id).
  @override
  Future<void> updateActivity(Activity activity) async {
    await _activitiesRef.doc(activity.id).update(activity.toJson()).timeout(_timeout);
  }

  /// Delete an activity by id.
  @override
  Future<void> deleteActivity(String id, DateTime date) async {
    await _activitiesRef.doc(id).delete().timeout(_timeout);
  }

  /// Get a list of all dates that have tracked activities.
  @override
  Future<List<DateTime>> getTrackedDates() async {
    final snap = await _activitiesRef.orderBy('date').get().timeout(_timeout);
    final dateStrings = <String>{};
    for (final doc in snap.docs) {
      final d = doc.data()['date'] as String?;
      if (d != null) dateStrings.add(d);
    }
    return dateStrings.map((s) {
      final parts = s.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }).toList()..sort();
  }

  /// Migrate local activities to Firestore (one-time sync).
  Future<void> importActivities(List<Activity> activities) async {
    final batch = _firestore.batch();
    for (final activity in activities) {
      batch.set(_activitiesRef.doc(activity.id), activity.toJson());
    }
    await batch.commit();
  }
}
