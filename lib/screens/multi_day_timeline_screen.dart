import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Screen showing a multi-day 24-hour timeline grid — one row per day,
/// with all activity types shown as colored blocks across a 0–23h axis.
class MultiDayTimelineScreen extends StatefulWidget {
  final StorageService storage;

  const MultiDayTimelineScreen({super.key, required this.storage});

  @override
  State<MultiDayTimelineScreen> createState() => _MultiDayTimelineScreenState();
}

class _MultiDayTimelineScreenState extends State<MultiDayTimelineScreen> {
  /// Number of days to show (including today).
  int _dayCount = 7;
  bool _isLoading = true;

  /// date → activities, ordered newest-first.
  final List<_DayData> _days = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<_DayData> loaded = [];

    for (int i = 0; i < _dayCount; i++) {
      final date = today.subtract(Duration(days: i));
      final activities = await widget.storage.getActivitiesForDate(date);
      loaded.add(_DayData(date: date, activities: activities));
    }

    setState(() {
      _days
        ..clear()
        ..addAll(loaded);
      _isLoading = false;
    });
  }

  void _setDayCount(int count) {
    if (count != _dayCount) {
      _dayCount = count;
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final labelColor = Theme.of(
      context,
    ).colorScheme.onSurface.withAlpha(isLight ? 140 : 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Overview'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_view_week),
            tooltip: 'Days to show',
            onSelected: _setDayCount,
            itemBuilder: (_) => [
              for (final n in [3, 5, 7, 14, 30])
                PopupMenuItem(value: n, child: Text('$n days')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Legend ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: _buildLegend(context, brightness),
                ),
                // ── Hour header ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildHourHeader(context, labelColor),
                ),
                const SizedBox(height: 4),
                // ── Day rows ──
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: _days.length,
                    itemBuilder: (context, index) {
                      return _DayRow(
                        data: _days[index],
                        brightness: brightness,
                        isToday: index == 0,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // ── Legend ──────────────────────────────────────────────────────────────────
  Widget _buildLegend(BuildContext context, Brightness brightness) {
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: ActivityType.values.map((t) {
        final color = AppTheme.colorForActivity(t.name, brightness);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color.withAlpha(180),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                AppTheme.iconForActivity(t.name),
                size: 10,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              AppTheme.labelForActivity(t.name),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontSize: 10),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ── Hour axis header (shared across all rows) ──────────────────────────────
  Widget _buildHourHeader(BuildContext context, Color labelColor) {
    // Left gutter width matches _DayRow's date label width.
    const double gutterWidth = 52;
    return Row(
      children: [
        const SizedBox(width: gutterWidth),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              return SizedBox(
                height: 16,
                child: Stack(
                  children: [
                    for (int h = 0; h <= 24; h += 3)
                      Positioned(
                        left: (h / 24.0) * totalWidth - 6,
                        top: 0,
                        child: Text(
                          h == 24 ? '' : h.toString().padLeft(2, '0'),
                          style: TextStyle(fontSize: 9, color: labelColor),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Internal data holder ──────────────────────────────────────────────────────
class _DayData {
  final DateTime date;
  final List<Activity> activities;

  const _DayData({required this.date, required this.activities});
}

// ── Single day row ────────────────────────────────────────────────────────────
class _DayRow extends StatelessWidget {
  final _DayData data;
  final Brightness brightness;
  final bool isToday;

  const _DayRow({
    required this.data,
    required this.brightness,
    required this.isToday,
  });

  static const double _gutterWidth = 52;
  static const double _rowHeight = 28;

  @override
  Widget build(BuildContext context) {
    final trackColor = AppTheme.trackColor(brightness);
    final dateLabel = _formatDate(data.date);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Row(
        children: [
          // ── Date label ──
          SizedBox(
            width: _gutterWidth,
            child: Text(
              dateLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withAlpha(180),
                fontSize: 11,
              ),
            ),
          ),
          // ── Timeline track ──
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                return SizedBox(
                  height: _rowHeight,
                  child: Stack(
                    children: [
                      // Background track
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: trackColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      // Activity blocks
                      ..._buildBlocks(totalWidth),
                      // "Today" now-line
                      if (isToday) _buildNowLine(totalWidth, context),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBlocks(double totalWidth) {
    return data.activities.map((a) {
      final color = AppTheme.colorForActivity(a.type.name, brightness);
      final startFrac = _timeToFraction(a.startTime);
      final endFrac = a.endTime != null
          ? _timeToFraction(a.endTime!)
          : (startFrac + 0.008).clamp(0.0, 1.0);
      final left = startFrac * totalWidth;
      final width = ((endFrac - startFrac) * totalWidth).clamp(3.0, totalWidth);

      return Positioned(
        left: left,
        width: width,
        top: 2,
        bottom: 2,
        child: Tooltip(
          message: _tooltipFor(a),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: width >= 18
                ? Icon(
                    AppTheme.iconForActivity(a.type.name),
                    size: 13,
                    color: Colors.white.withAlpha(220),
                  )
                : null,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNowLine(double totalWidth, BuildContext context) {
    final now = DateTime.now();
    final frac = (now.hour + now.minute / 60.0) / 24.0;
    final color = Theme.of(context).colorScheme.error;
    return Positioned(
      left: frac * totalWidth - 1,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        decoration: BoxDecoration(
          color: color.withAlpha(200),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  double _timeToFraction(DateTime dt) {
    return ((dt.hour + dt.minute / 60.0) / 24.0).clamp(0.0, 1.0);
  }

  String _tooltipFor(Activity a) {
    final label = AppTheme.labelForActivity(a.type.name);
    final start =
        '${a.startTime.hour.toString().padLeft(2, '0')}:${a.startTime.minute.toString().padLeft(2, '0')}';
    if (a.endTime != null) {
      final end =
          '${a.endTime!.hour.toString().padLeft(2, '0')}:${a.endTime!.minute.toString().padLeft(2, '0')}';
      return '$label  $start → $end';
    }
    return '$label  $start';
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(d.year, d.month, d.day);
    if (date == today) return 'Today';
    if (date == today.subtract(const Duration(days: 1))) return 'Yest.';
    return DateFormat('E d/M').format(d);
  }
}
