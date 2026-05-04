import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/health/health_service.dart';
import '../../home/providers/home_provider.dart';
import '../models/activity_session.dart';

part 'activity_provider.g.dart';

class ActivityState {
  const ActivityState({
    required this.weeklySteps,
    required this.activitySessions,
  });

  final List<int> weeklySteps;
  final List<ActivitySession> activitySessions;
}

@riverpod
Future<ActivityState> activity(Ref ref) async {
  final bool demoMode = ref.watch(demomodeProvider);
  final int todaySteps = ref.read(homeControllerProvider).todaySteps;
  final List<int> weeklySteps = demoMode
      ? demoWeeklySteps
      : await _loadWeeklySteps(todaySteps: todaySteps);
  final List<ActivitySession> sessions =
      _buildSessions(weeklySteps: weeklySteps);

  return ActivityState(
    weeklySteps: weeklySteps,
    activitySessions: sessions,
  );
}

Future<List<int>> _loadWeeklySteps({required int todaySteps}) async {
  try {
    final HealthService healthService = HealthService();
    final List<int> daily = await healthService.getWeeklyStepTotals();

    if (daily.every((value) => value == 0)) {
      return _fallbackWeeklySteps(todaySteps: todaySteps);
    }

    return daily;
  } catch (_) {
    return _fallbackWeeklySteps(todaySteps: todaySteps);
  }
}

List<int> _fallbackWeeklySteps({required int todaySteps}) {
  final List<int> mock = <int>[4200, 7800, 6100, 9200, 5500, 8900, 7000];
  final int todayIndex = DateTime.now().weekday - 1;
  mock[todayIndex] = todaySteps > 0 ? todaySteps : mock[todayIndex];
  return mock;
}

List<ActivitySession> _buildSessions({required List<int> weeklySteps}) {
  final DateTime now = DateTime.now();
  final int todayIndex = now.weekday - 1;
  final int todaySteps = weeklySteps[todayIndex];

  final Random random = Random(now.year * 1000 + now.month * 100 + now.day);
  final int sessionCount = 2 + random.nextInt(2);

  final List<ActivitySession> sessions = <ActivitySession>[];
  int remainingSteps = max(2400, todaySteps);

  for (int i = 0; i < sessionCount; i++) {
    final bool isRun = i == 0 ? random.nextBool() : random.nextDouble() > 0.65;
    final int duration =
        isRun ? 18 + random.nextInt(25) : 22 + random.nextInt(38);
    final int sessionSteps = i == sessionCount - 1
        ? max(1200, remainingSteps)
        : max(1000,
            (remainingSteps * (0.28 + random.nextDouble() * 0.22)).round());

    remainingSteps = max(1200, remainingSteps - sessionSteps);

    sessions.add(
      ActivitySession(
        type: isRun ? ActivityType.run : ActivityType.walk,
        duration: duration,
        steps: sessionSteps,
        startTime: now.subtract(
            Duration(hours: (i + 1) * 3, minutes: random.nextInt(50))),
      ),
    );
  }

  sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
  return sessions;
}
