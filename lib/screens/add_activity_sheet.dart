import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/adaptive_pickers.dart';

/// Bottom-sheet for adding or editing an activity.
class AddActivitySheet extends StatefulWidget {
  final Activity? existingActivity;
  final DateTime? initialDate;

  const AddActivitySheet({super.key, this.existingActivity, this.initialDate});

  @override
  State<AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<AddActivitySheet> {
  late ActivityType _type;
  late DateTime _startTime;
  DateTime? _endTime;
  DiaperType? _diaperType;
  double? _formulaAmountMl;
  String? _notes;
  List<BreastFeedingDetail>? _breastFeedingDetails;
  List<_SideEntry> _sideEntries = [];

  final _formulaController = TextEditingController();
  final _notesController = TextEditingController();

  bool get _isEditing => widget.existingActivity != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final a = widget.existingActivity!;
      _type = a.type;
      _startTime = a.startTime;
      _endTime = a.endTime;
      _diaperType = a.diaperType;
      _formulaAmountMl = a.formulaAmountMl;
      _notes = a.notes;
      _breastFeedingDetails = a.breastFeedingDetails != null
          ? List.of(a.breastFeedingDetails!)
          : null;
      _sideEntries = (a.breastFeedingDetails ?? [])
          .map(
            (d) => _SideEntry(
              side: d.side,
              startTime: d.startTime,
              endTime: d.endTime,
            ),
          )
          .toList();
      if (_sideEntries.isEmpty) {
        _sideEntries = [_SideEntry(side: 'left', startTime: a.startTime)];
      }
      if (_formulaAmountMl != null) {
        _formulaController.text = _formulaAmountMl!.round().toString();
      }
      if (_notes != null) {
        _notesController.text = _notes!;
      }
    } else {
      _type = ActivityType.breastFeeding;
      final date = widget.initialDate ?? DateTime.now();
      final now = DateTime.now();
      // Use current time if the selected date is today, otherwise default to noon.
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        _startTime = now;
      } else {
        _startTime = DateTime(date.year, date.month, date.day, 12, 0);
      }
      _sideEntries = [_SideEntry(side: 'left', startTime: _startTime)];
    }
  }

  @override
  void dispose() {
    _formulaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showAdaptiveDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Update start time to keep the same time-of-day on the new date.
        _startTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _startTime.hour,
          _startTime.minute,
        );
        // Update end time similarly if set.
        if (_endTime != null) {
          _endTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _endTime!.hour,
            _endTime!.minute,
          );
        }
      });
    }
  }

  Future<void> _pickSideTime(int index, {required bool isStart}) async {
    final entry = _sideEntries[index];
    final initial = isStart
        ? entry.startTime
        : (entry.endTime ?? entry.startTime);
    final picked = await showAdaptiveTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (picked != null) {
      setState(() {
        final base = _startTime;
        final dt = DateTime(
          base.year,
          base.month,
          base.day,
          picked.hour,
          picked.minute,
        );
        if (isStart) {
          _sideEntries[index] = entry.copyWith(startTime: dt);
        } else {
          _sideEntries[index] = entry.copyWith(endTime: dt);
        }
      });
    }
  }

  void _toggleSide(int index) {
    setState(() {
      final entry = _sideEntries[index];
      _sideEntries[index] = entry.copyWith(
        side: entry.side == 'left' ? 'right' : 'left',
      );
    });
  }

  void _addSideEntry() {
    final lastEnd = _sideEntries.last.endTime ?? _sideEntries.last.startTime;
    setState(() {
      _sideEntries.add(
        _SideEntry(
          side: _sideEntries.last.side == 'left' ? 'right' : 'left',
          startTime: lastEnd,
        ),
      );
    });
  }

  void _removeSideEntry(int index) {
    if (_sideEntries.length > 1) {
      setState(() => _sideEntries.removeAt(index));
    }
  }

  /// Sync _breastFeedingDetails and _endTime from the current side entries.
  void _syncBreastFeedingDetails() {
    _breastFeedingDetails = _sideEntries
        .map(
          (e) => BreastFeedingDetail(
            side: e.side,
            startTime: e.startTime,
            endTime: e.endTime,
          ),
        )
        .toList();
    final lastEnd = _sideEntries
        .where((e) => e.endTime != null)
        .map((e) => e.endTime!)
        .fold<DateTime?>(null, (prev, e) {
          if (prev == null || e.isAfter(prev)) return e;
          return prev;
        });
    if (lastEnd != null) _endTime = lastEnd;
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : (_endTime ?? _startTime);
    final picked = await showAdaptiveTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (picked != null) {
      setState(() {
        final base = _startTime;
        final dt = DateTime(
          base.year,
          base.month,
          base.day,
          picked.hour,
          picked.minute,
        );
        if (isStart) {
          _startTime = dt;
        } else {
          _endTime = dt;
        }
      });
    }
  }

  void _save() {
    final provider = context.read<ActivityProvider>();
    _notes = _notesController.text.isEmpty ? null : _notesController.text;

    if (_type == ActivityType.formulaFeeding) {
      final parsed = double.tryParse(_formulaController.text);
      _formulaAmountMl = parsed;
    }

    if (_type == ActivityType.breastFeeding) {
      _syncBreastFeedingDetails();
    }

    if (_isEditing) {
      provider.updateActivity(
        widget.existingActivity!.copyWith(
          type: _type,
          startTime: _startTime,
          endTime: _endTime,
          notes: _notes,
          breastFeedingDetails: _breastFeedingDetails,
          formulaAmountMl: _formulaAmountMl,
          diaperType: _diaperType,
          clearEndTime: _endTime == null,
          clearNotes: _notes == null,
        ),
      );
    } else {
      provider.addActivity(
        type: _type,
        startTime: _startTime,
        endTime: _endTime,
        notes: _notes,
        breastFeedingDetails: _breastFeedingDetails,
        formulaAmountMl: _formulaAmountMl,
        diaperType: _diaperType,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
                color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              _isEditing ? 'Edit Activity' : 'Log Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // ── Activity type selector ──
            _buildTypeSelector(brightness),
            const SizedBox(height: 16),

            // ── Date picker ──
            _buildDatePicker(),
            const SizedBox(height: 12),

            // ── Time pickers ──
            _buildTimePickers(),
            const SizedBox(height: 16),

            // ── Type-specific fields ──
            ..._buildTypeSpecificFields(brightness),

            // ── Notes ──
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 1,
            ),
            const SizedBox(height: 24),

            // ── Save button ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _save,
                icon: Icon(_isEditing ? Icons.check : Icons.add),
                label: Text(_isEditing ? 'Update' : 'Save'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Activity type toggle chips ────────────────────────────────────────────
  Widget _buildTypeSelector(Brightness brightness) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: ActivityType.values.map((t) {
        final selected = _type == t;
        final color = AppTheme.colorForActivity(t.name, brightness);
        return ChoiceChip(
          avatar: Icon(
            AppTheme.iconForActivity(t.name),
            size: 20,
            color: selected ? Colors.white : color,
          ),
          label: Text(AppTheme.labelForActivity(t.name)),
          selected: selected,
          selectedColor: color,
          labelStyle: TextStyle(
            color: selected ? Colors.white : null,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
          onSelected: (_) => setState(() => _type = t),
        );
      }).toList(),
    );
  }

  // ── Date picker button ─────────────────────────────────────────────────
  Widget _buildDatePicker() {
    final dateFmt = DateFormat('EEE, d MMM yyyy');
    return OutlinedButton.icon(
      onPressed: _pickDate,
      icon: const Icon(Icons.calendar_today, size: 18),
      label: Text(dateFmt.format(_startTime)),
    );
  }

  // ── Start / End time buttons ──────────────────────────────────────────────
  Widget _buildTimePickers() {
    final timeFmt = DateFormat.Hm();
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickTime(isStart: true),
            icon: const Icon(Icons.access_time),
            label: Text('Start: ${timeFmt.format(_startTime)}'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickTime(isStart: false),
            icon: const Icon(Icons.access_time_filled),
            label: Text(
              _endTime != null
                  ? 'End: ${timeFmt.format(_endTime!)}'
                  : 'End: --:--',
            ),
          ),
        ),
      ],
    );
  }

  // ── Extra fields per activity type ────────────────────────────────────────
  List<Widget> _buildTypeSpecificFields(Brightness brightness) {
    switch (_type) {
      case ActivityType.breastFeeding:
        return [
          ..._sideEntries.asMap().entries.map((mapEntry) {
            final idx = mapEntry.key;
            final entry = mapEntry.value;
            return _buildSideCard(idx, entry);
          }),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: _addSideEntry,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Add another side'),
          ),
        ];
      case ActivityType.formulaFeeding:
        return [
          TextField(
            controller: _formulaController,
            decoration: const InputDecoration(
              labelText: 'Amount (ml)',
              prefixIcon: Icon(Icons.local_drink),
            ),
            keyboardType: TextInputType.number,
          ),
        ];
      case ActivityType.diaper:
        return [
          Wrap(
            spacing: 10,
            children: DiaperType.values.map((d) {
              final selected = _diaperType == d;
              return ChoiceChip(
                label: Text(d.name[0].toUpperCase() + d.name.substring(1)),
                selected: selected,
                selectedColor: AppTheme.colorForActivity('diaper', brightness),
                labelStyle: TextStyle(color: selected ? Colors.white : null),
                avatar: Icon(
                  d == DiaperType.wet
                      ? Icons.water_drop
                      : d == DiaperType.dirty
                      ? Icons.cloud
                      : Icons.all_inclusive,
                  size: 18,
                ),
                onSelected: (_) => setState(() => _diaperType = d),
              );
            }).toList(),
          ),
        ];
      case ActivityType.sleep:
        return []; // just start/end time + notes
    }
  }

  // ── Breast feeding side card ──────────────────────────────────────────────
  Widget _buildSideCard(int index, _SideEntry entry) {
    final timeFmt = DateFormat.Hm();
    final theme = Theme.of(context);
    final isLeft = entry.side == 'left';
    final sideColor = isLeft ? AppTheme.leftSideColor : AppTheme.rightSideColor;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleSide(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
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
                        const SizedBox(width: 4),
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
                if (_sideEntries.length > 1)
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _removeSideEntry(index),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickSideTime(index, isStart: true),
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(timeFmt.format(entry.startTime)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickSideTime(index, isStart: false),
                    icon: const Icon(Icons.access_time_filled, size: 16),
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

/// Internal mutable helper for side entry state.
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
