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
      body: Stack(
        children: <Widget>[
          const _ActivityBackgroundGlow(),
          SafeArea(
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
                final int totalSteps = payload.steps
                    .fold<int>(0, (int sum, int value) => sum + value);
                final int activeMinutes = state.activitySessions.fold<int>(
                    0,
                    (int sum, ActivitySession session) =>
                        sum + session.duration);
                final int sessionCount = state.activitySessions.length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _ActivityHeroCard(
                        selectedRange: _selectedRange,
                        totalSteps: totalSteps,
                        activeMinutes: activeMinutes,
                        sessionCount: sessionCount,
                        onRangeChanged: (ActivityRange range) {
                          setState(() => _selectedRange = range);
                        },
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      _ActivityDonutCard(sessions: state.activitySessions),
                      const SizedBox(height: 16),
                      const _SectionHeader(
                        title: 'Recent Sessions',
                        subtitle: 'The latest activities from your day.',
                      ),
                      const SizedBox(height: 10),
                      if (state.activitySessions.isEmpty)
                        const _EmptySessionsCard()
                      else
                        ListView.separated(
                          itemCount: state.activitySessions.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, int index) {
                            return TweenAnimationBuilder<double>(
                              duration:
                                  Duration(milliseconds: 260 + (index * 80)),
                              curve: Curves.easeOutCubic,
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (BuildContext context, double value,
                                  Widget? child) {
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
        ],
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
      final int weeklyTotal =
          weeklySteps.fold<int>(0, (sum, item) => sum + item);
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

class _ActivityHeroCard extends StatelessWidget {
  const _ActivityHeroCard({
    required this.selectedRange,
    required this.totalSteps,
    required this.activeMinutes,
    required this.sessionCount,
    required this.onRangeChanged,
  });

  final ActivityRange selectedRange;
  final int totalSteps;
  final int activeMinutes;
  final int sessionCount;
  final ValueChanged<ActivityRange> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final String subtitle = switch (selectedRange) {
      ActivityRange.today => 'Today\'s movement snapshot',
      ActivityRange.week => 'Your weekly activity rhythm',
      ActivityRange.month => 'Monthly momentum at a glance',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF172554),
            Color(0xFF0F172A),
            Color(0xFF111827)
          ],
        ),
        border:
            Border.all(color: const Color(0xFF334155).withValues(alpha: 0.6)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF020617).withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFF22D3EE).withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: Color(0xFF22D3EE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Activity',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxWidth < 360;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _ActivityStatTile(
                    label: 'Steps',
                    value: '$totalSteps',
                    icon: Icons.directions_walk_rounded,
                    accent: const Color(0xFF6366F1),
                    compact: compact,
                  ),
                  _ActivityStatTile(
                    label: 'Active min',
                    value: '$activeMinutes',
                    icon: Icons.timer_outlined,
                    accent: const Color(0xFF22D3EE),
                    compact: compact,
                  ),
                  _ActivityStatTile(
                    label: 'Sessions',
                    value: '$sessionCount',
                    icon: Icons.fitness_center_rounded,
                    accent: const Color(0xFFFBBF24),
                    compact: compact,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _Header(
            selectedRange: selectedRange,
            onChanged: onRangeChanged,
          ),
        ],
      ),
    );
  }
}

class _ActivityStatTile extends StatelessWidget {
  const _ActivityStatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.compact,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact
          ? double.infinity
          : (MediaQuery.of(context).size.width - 64) / 3,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
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
    final double maxY = (values.reduce((a, b) => a > b ? a : b) * 1.25)
        .clamp(1000, 50000)
        .toDouble();

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
                barGroups: List<BarChartGroupData>.generate(values.length,
                    (int index) {
                  final bool isToday = index == highlightIndex;
                  final double opacity = isToday ? 1 : 0.6;
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4,
                    barRods: <BarChartRodData>[
                      BarChartRodData(
                        toY: values[index].toDouble(),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
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
    final double walkingValue = (walkingMinutes == 0 && runningMinutes == 0)
        ? 1
        : walkingMinutes.toDouble();
    final double runningValue = (walkingMinutes == 0 && runningMinutes == 0)
        ? 1
        : runningMinutes.toDouble();

    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionHeader(
            title: 'Activity Type',
            subtitle: 'Where your time was spent today.',
          ),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActivityBackgroundGlow extends StatelessWidget {
  const _ActivityBackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -80,
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    const Color(0xFF6366F1).withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 260,
            right: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    const Color(0xFF22D3EE).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySessionsCard extends StatelessWidget {
  const _EmptySessionsCard();

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      child: Column(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.north_east_rounded,
                color: AppTheme.primaryAccent),
          ),
          const SizedBox(height: 12),
          Text(
            'No sessions yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            'Your tracked sessions will appear here as you move today.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              height: 1.35,
            ),
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
