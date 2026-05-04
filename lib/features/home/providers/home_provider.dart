import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/health/health_service.dart';

part 'home_provider.g.dart';

const List<int> demoWeeklySteps = <int>[
  4200,
  7800,
  6100,
  9200,
  5500,
  8900,
  7342
];

final StateProvider<bool> demomodeProvider = StateProvider<bool>((Ref ref) {
  unawaited(() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    ref.read(demomodeProvider.notifier).state =
        prefs.getBool('demo_mode') ?? false;
  }());
  return false;
});

class HomeState {
  const HomeState({
    required this.todaySteps,
    required this.dailyGoal,
    required this.activityStatus,
    required this.insightText,
    required this.heartRate,
    required this.calories,
    required this.heartRateTrend,
  });

  const HomeState.initial()
      : todaySteps = 0,
        dailyGoal = 10000,
        activityStatus = ActivityStatus.idle,
        insightText = "Start moving, you've barely begun today!",
        heartRate = 72,
        calories = 0,
        heartRateTrend = const <int>[72, 73, 71, 74, 72];

  final int todaySteps;
  final int dailyGoal;
  final ActivityStatus activityStatus;
  final String insightText;
  final int heartRate;
  final int calories;
  final List<int> heartRateTrend;

  double get distanceKm => todaySteps * 0.000762;

  String get distanceFormatted => '${distanceKm.toStringAsFixed(2)} km';

  HomeState copyWith({
    int? todaySteps,
    int? dailyGoal,
    ActivityStatus? activityStatus,
    String? insightText,
    int? heartRate,
    int? calories,
    List<int>? heartRateTrend,
  }) {
    return HomeState(
      todaySteps: todaySteps ?? this.todaySteps,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      activityStatus: activityStatus ?? this.activityStatus,
      insightText: insightText ?? this.insightText,
      heartRate: heartRate ?? this.heartRate,
      calories: calories ?? this.calories,
      heartRateTrend: heartRateTrend ?? this.heartRateTrend,
    );
  }
}

@riverpod
class HomeController extends _$HomeController {
  static const int _demoSteps = 7342;
  static const int _demoBpm = 88;
  static const int _demoCalories = 294;
  static const ActivityStatus _demoStatus = ActivityStatus.walking;
  static const int _demoGoal = 10000;

  StreamSubscription<int>? _stepSubscription;
  StreamSubscription<ActivityStatus>? _activitySubscription;
  final HealthService _healthService = HealthService();
  bool _started = false;

  @override
  HomeState build() {
    ref.listen<bool>(demomodeProvider, (_, __) => ref.invalidateSelf());
    ref.onDispose(_dispose);

    final bool demoMode = ref.watch(demomodeProvider);
    if (demoMode) {
      _dispose();
      return const HomeState(
        todaySteps: _demoSteps,
        dailyGoal: _demoGoal,
        activityStatus: _demoStatus,
        insightText: 'Nice walk! Every step counts 👟',
        heartRate: _demoBpm,
        calories: _demoCalories,
        heartRateTrend: <int>[84, 86, 87, 90, 88],
      );
    }

    if (!_started) {
      _started = true;
      unawaited(_startDataSources());
    }

    return const HomeState.initial();
  }

  void _dispose() {
    _stepSubscription?.cancel();
    _activitySubscription?.cancel();
  }

  Future<void> _startDataSources() async {
    final bool permissionsGranted =
        await _healthService.requestActivityPermissions();
    debugPrint('home: activity permissions granted=$permissionsGranted');

    _activitySubscription = _healthService.activityStream.listen(
      (ActivityStatus status) {
        _updateState(
          todaySteps: state.todaySteps,
          activityStatus: status,
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('home: activity stream error: $error');
      },
    );

    try {
      _stepSubscription = _healthService.stepStream.listen(
        (int rawSteps) => unawaited(_onStepReading(rawSteps)),
        onError: (Object error, StackTrace stackTrace) =>
            unawaited(_onStepReading(0)),
      );
    } catch (_) {
      await _onStepReading(0);
    }
  }

  Future<void> _onStepReading(int rawSteps) async {
    int todaySteps = 0;

    try {
      todaySteps = await _healthService.getTodayStepsFromPedometer(rawSteps);
      if (todaySteps <= 0) {
        debugPrint('home: pedometer fallback triggered (raw=$rawSteps).');
        todaySteps = await _healthService.getTodayStepsFromHealth();
      }
    } catch (error) {
      debugPrint(
          'home: pedometer stream failed, trying health fallback: $error');
      todaySteps = await _healthService.getTodayStepsFromHealth();
    }

    if (todaySteps <= 0) {
      debugPrint('home: health fallback returned 0, using 0 steps.');
    } else {
      debugPrint('home: today steps=$todaySteps');
    }

    _updateState(
      todaySteps: todaySteps,
      activityStatus: state.activityStatus,
    );
  }

  String _insightForState({
    required int todaySteps,
    required int dailyGoal,
    required ActivityStatus activityStatus,
  }) {
    final int hour = DateTime.now().hour;

    if (todaySteps >= dailyGoal) {
      return "Goal crushed! You're amazing today 🏆";
    }
    if (todaySteps >= (dailyGoal * 0.8).round()) {
      return 'Almost there! Just ${dailyGoal - todaySteps} steps to go';
    }
    if (hour >= 20 && todaySteps < (dailyGoal * 0.5).round()) {
      return 'Evening reminder: only $todaySteps steps so far today';
    }
    if (hour < 10 && todaySteps < 500) {
      return "Great day ahead — let's start moving!";
    }
    if (activityStatus == ActivityStatus.running) {
      return "You're on fire! Keep that pace 🔥";
    }
    if (activityStatus == ActivityStatus.walking) {
      return 'Nice walk! Every step counts 👟';
    }
    return "You've taken $todaySteps steps — keep going!";
  }

  int _simulateHeartRate(ActivityStatus status) {
    final DateTime now = DateTime.now();
    final int minuteSeed = now.year * 10000000 +
        now.month * 100000 +
        now.day * 1000 +
        now.hour * 60 +
        now.minute;
    final Random random = Random(minuteSeed + status.index * 97);

    return switch (status) {
      ActivityStatus.idle => 68 + random.nextInt(8),
      ActivityStatus.walking => 85 + random.nextInt(16),
      ActivityStatus.running => 130 + random.nextInt(36),
    };
  }

  List<int> _buildHeartRateTrend(int latest, ActivityStatus status) {
    final int seed = DateTime.now().millisecondsSinceEpoch ~/ 60000;
    final Random random = Random(seed + status.index * 13);
    return List<int>.generate(
      5,
      (int index) => max(45, latest - (4 - index) * 2 + random.nextInt(5)),
    );
  }

  void _updateState({
    required int todaySteps,
    required ActivityStatus activityStatus,
  }) {
    final int calories = (todaySteps * 0.04).round();
    final int heartRate = _simulateHeartRate(activityStatus);
    state = state.copyWith(
      todaySteps: todaySteps,
      activityStatus: activityStatus,
      insightText: _insightForState(
        todaySteps: todaySteps,
        dailyGoal: state.dailyGoal,
        activityStatus: activityStatus,
      ),
      heartRate: heartRate,
      calories: calories,
      heartRateTrend: _buildHeartRateTrend(heartRate, activityStatus),
    );
  }

  void setDailyGoal(int goal) {
    state = state.copyWith(
      dailyGoal: goal.clamp(1000, 50000),
    );
  }
}
