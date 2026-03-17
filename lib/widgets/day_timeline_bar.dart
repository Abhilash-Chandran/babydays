import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../theme/app_theme.dart';

/// A horizontal 24-hour timeline bar showing activity blocks across the day.
class DayTimelineBar extends StatelessWidget {
  final List<Activity> activities;

  const DayTimelineBar({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final trackColor = AppTheme.trackColor(brightness);
    final labelColor = Theme.of(
      context,
    ).colorScheme.onSurface.withAlpha(isLight ? 140 : 100);
    final nowLineColor = Theme.of(context).colorScheme.error;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
            Row(
              children: [
                Icon(Icons.timeline, size: 18, color: labelColor),
                const SizedBox(width: 6),
                Text(
                  '24-Hour Overview',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ── Legend ──
            _buildLegend(context, brightness),
            const SizedBox(height: 10),
            // ── Timeline bar ──
            LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                return Column(
                  children: [
                    // ── Activity bars (stacked per type row) ──
                    _buildActivityRows(totalWidth, brightness, trackColor),
                    const SizedBox(height: 2),
                    // ── Hour labels + now indicator ──
                    _buildHourLabels(
                      totalWidth,
                      labelColor,
                      nowLineColor,
                      context,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Legend row ──────────────────────────────────────────────────────────────
  Widget _buildLegend(BuildContext context, Brightness brightness) {
    final types = ActivityType.values;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: types.map((t) {
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

  // ── One row per activity type with colored blocks ──────────────────────────
  Widget _buildActivityRows(
    double totalWidth,
    Brightness brightness,
    Color trackColor,
  ) {
    // Group activities by type, only show rows that have data.
    final grouped = <ActivityType, List<Activity>>{};
    for (final a in activities) {
      grouped.putIfAbsent(a.type, () => []).add(a);
    }

    if (grouped.isEmpty) {
      return SizedBox(
        height: 24,
        child: Container(
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }

    // Show in a fixed order
    final orderedTypes = ActivityType.values
        .where((t) => grouped.containsKey(t))
        .toList();

    return Column(
      children: orderedTypes.map((type) {
        final color = AppTheme.colorForActivity(type.name, brightness);
        final typeActivities = grouped[type]!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.5),
          child: SizedBox(
            height: 18,
            child: Stack(
              children: [
                // Track background
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Activity blocks
                ...typeActivities.map((a) {
                  final startFrac = _timeToFraction(a.startTime);
                  final endFrac = a.endTime != null
                      ? _timeToFraction(a.endTime!)
                      : (startFrac + 0.01).clamp(
                          0.0,
                          1.0,
                        ); // dot for instant events
                  final left = startFrac * totalWidth;
                  final width = ((endFrac - startFrac) * totalWidth).clamp(
                    3.0,
                    totalWidth,
                  );
                  return Positioned(
                    left: left,
                    width: width,
                    top: 0,
                    bottom: 0,
                    child: Tooltip(
                      message: _tooltipFor(a),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: width >= 16
                            ? Icon(
                                AppTheme.iconForActivity(a.type.name),
                                size: 12,
                                color: Colors.white.withAlpha(220),
                              )
                            : null,
                      ),
                    ),
                  );
                }),
                // Type icon at the start
                Positioned(
                  left: 2,
                  top: 1,
                  child: Icon(
                    AppTheme.iconForActivity(type.name),
                    size: 14,
                    color: brightness == Brightness.light
                        ? Colors.black45
                        : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Hour tick marks & labels ───────────────────────────────────────────────
  Widget _buildHourLabels(
    double totalWidth,
    Color labelColor,
    Color nowLineColor,
    BuildContext context,
  ) {
    final now = DateTime.now();
    final nowFrac = (now.hour + now.minute / 60.0) / 24.0;

    return SizedBox(
      height: 20,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Hour tick labels (every 3h) ──
          for (int h = 0; h <= 24; h += 3)
            Positioned(
              left: (h / 24.0) * totalWidth - 8,
              top: 2,
              child: Text(
                h == 24 ? '' : h.toString().padLeft(2, '0'),
                style: TextStyle(fontSize: 9, color: labelColor),
              ),
            ),
          // ── Now indicator ──
          Positioned(
            left: nowFrac * totalWidth - 0.5,
            top: -20, // extends up into the track area
            child: Container(
              width: 2,
              height: 38,
              decoration: BoxDecoration(
                color: nowLineColor.withAlpha(180),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          // "Now" label
          Positioned(
            left: (nowFrac * totalWidth - 10).clamp(0, totalWidth - 24),
            top: 9,
            child: Text(
              'now',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: nowLineColor.withAlpha(200),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
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
}
