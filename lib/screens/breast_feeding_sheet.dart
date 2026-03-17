import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../theme/app_theme.dart';

/// Bottom-sheet for entering left/right breast feeding side details.
class BreastFeedingSheet extends StatefulWidget {
  final DateTime startTime;
  final List<BreastFeedingDetail>? existing;

  const BreastFeedingSheet({super.key, required this.startTime, this.existing});

  @override
  State<BreastFeedingSheet> createState() => _BreastFeedingSheetState();
}

class _BreastFeedingSheetState extends State<BreastFeedingSheet> {
  late List<_SideEntry> _entries;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null && widget.existing!.isNotEmpty) {
      _entries = widget.existing!
          .map(
            (d) => _SideEntry(
              side: d.side,
              startTime: d.startTime,
              endTime: d.endTime,
            ),
          )
          .toList();
    } else {
      _entries = [_SideEntry(side: 'left', startTime: widget.startTime)];
    }
  }

  void _addEntry() {
    final lastEnd = _entries.last.endTime ?? _entries.last.startTime;
    setState(() {
      _entries.add(
        _SideEntry(
          side: _entries.last.side == 'left' ? 'right' : 'left',
          startTime: lastEnd,
        ),
      );
    });
  }

  void _removeEntry(int index) {
    if (_entries.length > 1) {
      setState(() => _entries.removeAt(index));
    }
  }

  Future<void> _pickTime(int index, {required bool isStart}) async {
    final entry = _entries[index];
    final initial = isStart
        ? entry.startTime
        : (entry.endTime ?? entry.startTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (picked != null) {
      setState(() {
        final dt = DateTime(
          widget.startTime.year,
          widget.startTime.month,
          widget.startTime.day,
          picked.hour,
          picked.minute,
        );
        if (isStart) {
          _entries[index] = entry.copyWith(startTime: dt);
        } else {
          _entries[index] = entry.copyWith(endTime: dt);
        }
      });
    }
  }

  void _toggleSide(int index) {
    setState(() {
      final entry = _entries[index];
      _entries[index] = entry.copyWith(
        side: entry.side == 'left' ? 'right' : 'left',
      );
    });
  }

  void _save() {
    final details = _entries
        .map(
          (e) => BreastFeedingDetail(
            side: e.side,
            startTime: e.startTime,
            endTime: e.endTime,
          ),
        )
        .toList();
    Navigator.pop(context, details);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ──
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Breast Feeding Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Log each side with start & end times',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            // ── Side entries ──
            ..._entries.asMap().entries.map((mapEntry) {
              final idx = mapEntry.key;
              final entry = mapEntry.value;
              return _buildSideCard(idx, entry, theme);
            }),

            const SizedBox(height: 8),
            // ── Add another side ──
            TextButton.icon(
              onPressed: _addEntry,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add another side'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(onPressed: _save, child: const Text('Done')),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSideCard(int index, _SideEntry entry, ThemeData theme) {
    final timeFmt = DateFormat.Hm();
    final isLeft = entry.side == 'left';
    final sideColor = isLeft ? AppTheme.leftSideColor : AppTheme.rightSideColor;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // ── Side toggle ──
                GestureDetector(
                  onTap: () => _toggleSide(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: sideColor.withAlpha(80),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLeft ? Icons.arrow_back : Icons.arrow_forward,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isLeft ? 'Left' : 'Right',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (_entries.length > 1)
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: theme.colorScheme.error,
                      size: 22,
                    ),
                    onPressed: () => _removeEntry(index),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(index, isStart: true),
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(timeFmt.format(entry.startTime)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(index, isStart: false),
                    icon: const Icon(Icons.access_time_filled, size: 18),
                    label: Text(
                      entry.endTime != null
                          ? timeFmt.format(entry.endTime!)
                          : '--:--',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal mutable helper for the sheet state.
class _SideEntry {
  String side;
  DateTime startTime;
  DateTime? endTime;

  _SideEntry({required this.side, required this.startTime, this.endTime});

  _SideEntry copyWith({
    String? side,
    DateTime? startTime,
    DateTime? endTime,
    bool clearEnd = false,
  }) {
    return _SideEntry(
      side: side ?? this.side,
      startTime: startTime ?? this.startTime,
      endTime: clearEnd ? null : (endTime ?? this.endTime),
    );
  }
}
