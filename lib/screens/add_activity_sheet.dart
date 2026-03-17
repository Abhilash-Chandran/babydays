import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/adaptive_pickers.dart';
import 'breast_feeding_sheet.dart';

/// Bottom-sheet for adding or editing an activity.
class AddActivitySheet extends StatefulWidget {
  final Activity? existingActivity;

  const AddActivitySheet({super.key, this.existingActivity});

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
      if (_formulaAmountMl != null) {
        _formulaController.text = _formulaAmountMl!.round().toString();
      }
      if (_notes != null) {
        _notesController.text = _notes!;
      }
    } else {
      _type = ActivityType.breastFeeding;
      _startTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    _formulaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : (_endTime ?? _startTime);
    final picked = await showAdaptiveTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (picked != null) {
      setState(() {
        final base = context.read<ActivityProvider>().selectedDate;
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

  Future<void> _openBreastFeedingDetails() async {
    final result = await showModalBottomSheet<List<BreastFeedingDetail>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BreastFeedingSheet(
        startTime: _startTime,
        existing: _breastFeedingDetails,
      ),
    );
    if (result != null) {
      setState(() {
        _breastFeedingDetails = result;
        // Auto-set the end time to the last detail's end time.
        final lastEnd = result
            .where((d) => d.endTime != null)
            .map((d) => d.endTime!)
            .fold<DateTime?>(null, (prev, e) {
              if (prev == null || e.isAfter(prev)) return e;
              return prev;
            });
        if (lastEnd != null) _endTime = lastEnd;
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
            const SizedBox(height: 20),

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
          OutlinedButton.icon(
            onPressed: _openBreastFeedingDetails,
            icon: const Icon(Icons.tune),
            label: Text(
              _breastFeedingDetails != null && _breastFeedingDetails!.isNotEmpty
                  ? '${_breastFeedingDetails!.length} side(s) logged'
                  : 'Add L/R side details',
            ),
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
}
