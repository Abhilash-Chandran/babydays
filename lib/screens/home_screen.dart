import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/adaptive_pickers.dart';
import '../widgets/day_timeline_bar.dart';
import 'add_activity_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load today's activities on first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadActivities();
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final provider = context.read<ActivityProvider>();
    final picked = await showAdaptiveDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      await provider.selectDate(picked);
    }
  }

  void _goToPreviousDay() {
    final provider = context.read<ActivityProvider>();
    provider.selectDate(
      provider.selectedDate.subtract(const Duration(days: 1)),
    );
  }

  void _goToNextDay() {
    final provider = context.read<ActivityProvider>();
    final next = provider.selectedDate.add(const Duration(days: 1));
    final today = DateTime.now();
    if (next.isBefore(DateTime(today.year, today.month, today.day + 1))) {
      provider.selectDate(next);
    }
  }

  void _openEditActivity(Activity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddActivitySheet(existingActivity: activity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityProvider>();
    final dateStr = _formatDateHeader(provider.selectedDate);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(title: const Text('BabyDays')),
      body: Column(
        children: [
          // ── Date navigation bar ──
          _buildDateBar(context, dateStr),
          // ── Activity summary chips ──
          _buildSummaryRow(provider.activities, brightness),
          const SizedBox(height: 4),
          // ── 24-hour visual timeline ──
          if (!provider.isLoading && provider.activities.isNotEmpty)
            DayTimelineBar(activities: provider.activities),
          const SizedBox(height: 4),
          // ── Timeline list ──
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.activities.isEmpty
                ? _buildEmptyState()
                : _buildTimeline(provider.activities, brightness),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddActivitySheet(),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // ── Date navigation ──────────────────────────────────────────────────────
  Widget _buildDateBar(BuildContext context, String dateStr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _goToPreviousDay,
          ),
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Text(
              dateStr,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _goToNextDay,
          ),
        ],
      ),
    );
  }

  // ── Summary chips ─────────────────────────────────────────────────────────
  Widget _buildSummaryRow(List<Activity> activities, Brightness brightness) {
    final counts = <ActivityType, int>{};
    for (final a in activities) {
      counts[a.type] = (counts[a.type] ?? 0) + 1;
    }
    if (counts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: counts.entries.map((e) {
          final color = AppTheme.colorForActivity(e.key.name, brightness);
          return Chip(
            avatar: Icon(
              AppTheme.iconForActivity(e.key.name),
              size: 18,
              color: brightness == Brightness.light
                  ? Colors.black87
                  : Colors.white,
            ),
            label: Text('${e.value}'),
            backgroundColor: color.withAlpha(80),
            side: BorderSide.none,
          );
        }).toList(),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.child_friendly,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withAlpha(120),
          ),
          const SizedBox(height: 16),
          Text(
            'No activities yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to log your baby\'s first entry',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // ── Timeline list ─────────────────────────────────────────────────────────
  Widget _buildTimeline(List<Activity> activities, Brightness brightness) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _ActivityCard(
          activity: activity,
          brightness: brightness,
          onTap: () => _openEditActivity(activity),
          onDelete: () =>
              context.read<ActivityProvider>().deleteActivity(activity),
        );
      },
    );
  }

  String _formatDateHeader(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(d.year, d.month, d.day);
    if (date == today) return 'Today — ${DateFormat.MMMd().format(d)}';
    if (date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday — ${DateFormat.MMMd().format(d)}';
    }
    return DateFormat.yMMMd().format(d);
  }
}

// ── Single activity card ──────────────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final Brightness brightness;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ActivityCard({
    required this.activity,
    required this.brightness,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.colorForActivity(activity.type.name, brightness);
    final timeFormat = DateFormat.Hm();

    return Dismissible(
      key: ValueKey(activity.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withAlpha(200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete activity?'),
            content: const Text('This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ── Icon circle ──
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withAlpha(60),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppTheme.iconForActivity(activity.type.name),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // ── Details ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTheme.labelForActivity(activity.type.name),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // ── Time ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeFormat.format(activity.startTime),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (activity.endTime != null)
                      Text(
                        '→ ${timeFormat.format(activity.endTime!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (activity.duration != null)
                      Text(
                        _formatDuration(activity.duration!),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitle() {
    switch (activity.type) {
      case ActivityType.breastFeeding:
        if (activity.breastFeedingDetails != null &&
            activity.breastFeedingDetails!.isNotEmpty) {
          final sides = activity.breastFeedingDetails!
              .map((d) => d.side[0].toUpperCase())
              .join(', ');
          return 'Sides: $sides';
        }
        return 'Breast feeding';
      case ActivityType.formulaFeeding:
        if (activity.formulaAmountMl != null) {
          return '${activity.formulaAmountMl!.round()} ml';
        }
        return 'Formula feed';
      case ActivityType.diaper:
        if (activity.diaperType != null) {
          return activity.diaperType!.name[0].toUpperCase() +
              activity.diaperType!.name.substring(1);
        }
        return 'Diaper change';
      case ActivityType.sleep:
        return activity.notes ?? 'Sleep';
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
