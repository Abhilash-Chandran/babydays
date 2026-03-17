import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Returns true if the current platform has an iOS/macOS look & feel.
bool _isCupertino(BuildContext context) {
  final platform = Theme.of(context).platform;
  return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}

/// Shows a platform-adaptive date picker.
/// Returns the selected [DateTime] or null if cancelled.
Future<DateTime?> showAdaptiveDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  if (_isCupertino(context)) {
    DateTime? result;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) {
        return Container(
          height: 300 + bottomPadding,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(ctx),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CupertinoToolbar(
                onCancel: () => Navigator.pop(ctx),
                onDone: () => Navigator.pop(ctx),
              ),
              SizedBox(
                height: 216,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: firstDate,
                  maximumDate: lastDate,
                  onDateTimeChanged: (dt) => result = dt,
                ),
              ),
              SizedBox(height: bottomPadding),
            ],
          ),
        );
      },
    );
    return result;
  }

  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );
}

/// Shows a platform-adaptive time picker.
/// Returns the selected [TimeOfDay] or null if cancelled.
Future<TimeOfDay?> showAdaptiveTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  if (_isCupertino(context)) {
    TimeOfDay? result;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) {
        return Container(
          height: 300 + bottomPadding,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(ctx),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CupertinoToolbar(
                onCancel: () => Navigator.pop(ctx),
                onDone: () => Navigator.pop(ctx),
              ),
              SizedBox(
                height: 216,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(
                    0,
                    1,
                    1,
                    initialTime.hour,
                    initialTime.minute,
                  ),
                  onDateTimeChanged: (dt) =>
                      result = TimeOfDay(hour: dt.hour, minute: dt.minute),
                ),
              ),
              SizedBox(height: bottomPadding),
            ],
          ),
        );
      },
    );
    return result;
  }

  return showTimePicker(context: context, initialTime: initialTime);
}

class _CupertinoToolbar extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onDone;

  const _CupertinoToolbar({required this.onCancel, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onPressed: onDone,
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
