import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../models/activity_session.dart';
import '../providers/activity_provider.dart';
import '../widgets/activity_session_card.dart';

enum ActivityRange { today, week, month }

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  ActivityRange _selectedRange = ActivityRange.week;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ActivityState> activityAsync = ref.watch(activityProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: activityAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Unable to load activity data.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          data: (ActivityState state) {
            final _ChartPayload payload = _chartPayloadFromRange(
              range: _selectedRange,
              weeklySteps: state.weeklySteps,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Header(
                    selectedRange: _selectedRange,
                    onChanged: (ActivityRange range) {
                      setState(() => _selectedRange = range);
                    },
                  ),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _WeeklyBarChartCard(
                      key: ValueKey<String>('bar-${_selectedRange.name}'),
                      labels: payload.labels,
                      values: payload.steps,
                      highlightIndex: payload.highlightIndex,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ActivityDonutCard(sessions: state.activitySessions),
                  const SizedBox(height: 18),
                  Text(
                    'Sessions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    itemCount: state.activitySessions.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, int index) {
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 260 + (index * 80)),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (BuildContext context, double value, Widget? child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 14 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: ActivitySessionCard(
                          session: state.activitySessions[index],
                          isActive: index == 0,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _ChartPayload _chartPayloadFromRange({
    required ActivityRange range,
    required List<int> weeklySteps,
  }) {
    final int todayIndex = DateTime.now().weekday - 1;

    if (range == ActivityRange.today) {
      final int todaySteps = weeklySteps[todayIndex];
      return _ChartPayload(
        labels: const <String>['Today'],
        steps: <int>[todaySteps],
        highlightIndex: 0,
      );
    }

    if (range == ActivityRange.month) {
      final int weeklyTotal = weeklySteps.fold<int>(0, (sum, item) => sum + item);
      final int avgWeek = (weeklyTotal / 7).round();
      return _ChartPayload(
        labels: const <String>['W1', 'W2', 'W3', 'W4'],
        steps: <int>[
          (avgWeek * 0.90).round() * 7,
          (avgWeek * 1.00).round() * 7,
          (avgWeek * 1.08).round() * 7,
          (avgWeek * 0.96).round() * 7,
        ],
        highlightIndex: 3,
      );
    }

    return _ChartPayload(
      labels: const <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      steps: weeklySteps,
      highlightIndex: todayIndex,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.selectedRange,
    required this.onChanged,
  });

  final ActivityRange selectedRange;
  final ValueChanged<ActivityRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Activity', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: <Widget>[
            _RangeChip(
              label: 'Today',
              selected: selectedRange == ActivityRange.today,
              onTap: () => onChanged(ActivityRange.today),
            ),
            _RangeChip(
              label: 'Week',
              selected: selectedRange == ActivityRange.week,
              onTap: () => onChanged(ActivityRange.week),
            ),
            _RangeChip(
              label: 'Month',
              selected: selectedRange == ActivityRange.month,
              onTap: () => onChanged(ActivityRange.month),
            ),
          ],
        ),
      ],
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryAccent.withValues(alpha: 0.28),
      backgroundColor: AppTheme.surface,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: Colors.white.withValues(alpha: selected ? 0.14 : 0.08),
        ),
      ),
    );
  }
}

class _WeeklyBarChartCard extends StatelessWidget {
  const _WeeklyBarChartCard({
    super.key,
    required this.labels,
    required this.values,
    required this.highlightIndex,
  });

  final List<String> labels;
  final List<int> values;
  final int highlightIndex;

  @override
  Widget build(BuildContext context) {
    final double maxY = (values.reduce((a, b) => a > b ? a : b) * 1.25).clamp(1000, 50000).toDouble();

    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Steps Overview', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.round()} steps',
                        const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final int i = value.toInt();
                        if (i < 0 || i >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[i],
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final int i = value.toInt();
                        if (i < 0 || i >= values.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          '${values[i]}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List<BarChartGroupData>.generate(values.length, (int index) {
                  final bool isToday = index == highlightIndex;
                  final double opacity = isToday ? 1 : 0.6;
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4,
                    barRods: <BarChartRodData>[
                      BarChartRodData(
                        toY: values[index].toDouble(),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            AppTheme.primaryAccent.withValues(alpha: opacity),
                            AppTheme.secondaryAccent.withValues(alpha: opacity),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
              swapAnimationDuration: const Duration(milliseconds: 650),
              swapAnimationCurve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityDonutCard extends StatelessWidget {
  const _ActivityDonutCard({required this.sessions});

  final List<ActivitySession> sessions;

  @override
  Widget build(BuildContext context) {
    int walkingMinutes = 0;
    int runningMinutes = 0;
    for (final ActivitySession session in sessions) {
      if (session.type == ActivityType.walk) {
        walkingMinutes += session.duration;
      } else {
        runningMinutes += session.duration;
      }
    }

    final int totalMinutes = walkingMinutes + runningMinutes;
    final double walkingValue = (walkingMinutes == 0 && runningMinutes == 0) ? 1 : walkingMinutes.toDouble();
    final double runningValue = (walkingMinutes == 0 && runningMinutes == 0) ? 1 : runningMinutes.toDouble();

    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Activity Type', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 60,
                    sections: <PieChartSectionData>[
                      PieChartSectionData(
                        value: walkingValue,
                        color: AppTheme.primaryAccent,
                        radius: 48,
                        title: '',
                      ),
                      PieChartSectionData(
                        value: runningValue,
                        color: AppTheme.secondaryAccent,
                        radius: 48,
                        title: '',
                      ),
                    ],
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 700),
                  swapAnimationCurve: Curves.easeOutCubic,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '$totalMinutes',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      'active min',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: <Widget>[
              _LegendDot(color: AppTheme.primaryAccent, label: 'Walking'),
              SizedBox(width: 16),
              _LegendDot(color: AppTheme.secondaryAccent, label: 'Running'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ChartPayload {
  const _ChartPayload({
    required this.labels,
    required this.steps,
    required this.highlightIndex,
  });

  final List<String> labels;
  final List<int> steps;
  final int highlightIndex;
}
