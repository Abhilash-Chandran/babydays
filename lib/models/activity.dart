import 'dart:convert';

/// Types of activities that can be tracked.
enum ActivityType { breastFeeding, formulaFeeding, diaper, sleep }

/// Sub-types for diaper changes.
enum DiaperType { wet, dirty, both }

/// Represents a single breast-feeding side entry within a feeding session.
class BreastFeedingDetail {
  final String side; // 'left' or 'right'
  final DateTime startTime;
  final DateTime? endTime;

  BreastFeedingDetail({
    required this.side,
    required this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() => {
    'side': side,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
  };

  factory BreastFeedingDetail.fromJson(Map<String, dynamic> json) {
    return BreastFeedingDetail(
      side: json['side'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
    );
  }

  BreastFeedingDetail copyWith({
    String? side,
    DateTime? startTime,
    DateTime? endTime,
    bool clearEndTime = false,
  }) {
    return BreastFeedingDetail(
      side: side ?? this.side,
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
    );
  }
}

/// A single tracked activity entry.
class Activity {
  final String id;
  final ActivityType type;
  final DateTime date; // date only (year, month, day)
  final DateTime startTime;
  final DateTime? endTime;
  final String? notes;

  // Breast feeding specific — a session can include left, right, or both.
  final List<BreastFeedingDetail>? breastFeedingDetails;

  // Formula feeding specific
  final double? formulaAmountMl;

  // Diaper specific
  final DiaperType? diaperType;

  Activity({
    required this.id,
    required this.type,
    required this.date,
    required this.startTime,
    this.endTime,
    this.notes,
    this.breastFeedingDetails,
    this.formulaAmountMl,
    this.diaperType,
  });

  /// Duration of the activity, or null if not yet ended.
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'date': _dateToString(date),
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'notes': notes,
    'breastFeedingDetails': breastFeedingDetails
        ?.map((d) => d.toJson())
        .toList(),
    'formulaAmountMl': formulaAmountMl,
    'diaperType': diaperType?.name,
  };

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      type: ActivityType.values.byName(json['type'] as String),
      date: _dateFromString(json['date'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      notes: json['notes'] as String?,
      breastFeedingDetails: json['breastFeedingDetails'] != null
          ? (json['breastFeedingDetails'] as List)
                .map(
                  (d) =>
                      BreastFeedingDetail.fromJson(d as Map<String, dynamic>),
                )
                .toList()
          : null,
      formulaAmountMl: json['formulaAmountMl'] != null
          ? (json['formulaAmountMl'] as num).toDouble()
          : null,
      diaperType: json['diaperType'] != null
          ? DiaperType.values.byName(json['diaperType'] as String)
          : null,
    );
  }

  Activity copyWith({
    String? id,
    ActivityType? type,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    List<BreastFeedingDetail>? breastFeedingDetails,
    double? formulaAmountMl,
    DiaperType? diaperType,
    bool clearEndTime = false,
    bool clearNotes = false,
  }) {
    return Activity(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      notes: clearNotes ? null : (notes ?? this.notes),
      breastFeedingDetails: breastFeedingDetails ?? this.breastFeedingDetails,
      formulaAmountMl: formulaAmountMl ?? this.formulaAmountMl,
      diaperType: diaperType ?? this.diaperType,
    );
  }

  /// Encode a list of activities to a JSON string.
  static String encodeList(List<Activity> activities) {
    return jsonEncode(activities.map((a) => a.toJson()).toList());
  }

  /// Decode a JSON string to a list of activities.
  static List<Activity> decodeList(String jsonString) {
    final list = jsonDecode(jsonString) as List;
    return list
        .map((item) => Activity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Helpers for date-only serialization (yyyy-MM-dd).
  static String _dateToString(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _dateFromString(String s) {
    final parts = s.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
