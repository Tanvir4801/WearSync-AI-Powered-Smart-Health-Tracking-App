import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/daily_steps.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  final Health health = Health();

  factory HealthService() {
    return _instance;
  }

  HealthService._internal();

  Future<bool> requestActivityPermissions() async {
    try {
      final PermissionStatus recognition =
          await Permission.activityRecognition.request();
      final PermissionStatus sensors = await Permission.sensors.request();
      return recognition.isGranted || sensors.isGranted;
    } catch (_) {
      return false;
    }
  }

  Stream<int> get stepStream {
    return Pedometer.stepCountStream.transform<int>(
      StreamTransformer<StepCount, int>.fromHandlers(
        handleData: (StepCount event, EventSink<int> sink) {
          sink.add(event.steps);
        },
        handleError:
            (Object error, StackTrace stackTrace, EventSink<int> sink) {
          debugPrint('Pedometer step stream error: $error');
          sink.add(0);
        },
      ),
    );
  }

  Stream<ActivityStatus> get activityStream {
    return Pedometer.pedestrianStatusStream.transform<ActivityStatus>(
      StreamTransformer<PedestrianStatus, ActivityStatus>.fromHandlers(
        handleData: (PedestrianStatus event, EventSink<ActivityStatus> sink) {
          switch (event.status) {
            case 'walking':
              sink.add(ActivityStatus.walking);
            case 'running':
              sink.add(ActivityStatus.running);
            default:
              sink.add(ActivityStatus.idle);
          }
        },
        handleError: (Object error, StackTrace stackTrace,
            EventSink<ActivityStatus> sink) {
          debugPrint('Pedometer status stream error: $error');
          sink.add(ActivityStatus.idle);
        },
      ),
    );
  }

  Future<int> getTodayStepsFromPedometer(int currentStepCount) async {
    if (currentStepCount <= 0) {
      return 0;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String dateKey = _dateKey(DateTime.now());
    final String baselineKey = 'steps_baseline_$dateKey';
    final int? baseline = prefs.getInt(baselineKey);

    if (baseline == null) {
      await prefs.setInt(baselineKey, currentStepCount);
      return 0;
    }

    return max(0, currentStepCount - baseline);
  }

  Future<int> getTodayStepsFromHealth() async {
    try {
      final DateTime now = DateTime.now();
      final DateTime midnight = DateTime(now.year, now.month, now.day);

      final bool requested = await health.requestAuthorization(
        <HealthDataType>[HealthDataType.STEPS],
        permissions: <HealthDataAccess>[HealthDataAccess.READ],
      );

      if (!requested) {
        return 0;
      }

      final int? steps = await health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (_) {
      return 0;
    }
  }

  final List<HealthDataType> _types = <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
    HealthDataType.SLEEP_ASLEEP,
  ];

  Future<bool> requestPermissions() async {
    try {
      final bool hasPermissions = await health.requestAuthorization(_types);
      return hasPermissions;
    } catch (e) {
      return false;
    }
  }

  Future<int> getTodaySteps() async {
    return getTodayStepsFromHealth();
  }

  Future<List<DailySteps>> getWeeklySteps() async {
    try {
      final List<DailySteps> weeklySteps = <DailySteps>[];
      final DateTime now = DateTime.now();

      for (int i = 6; i >= 0; i--) {
        final DateTime date = now.subtract(Duration(days: i));
        final DateTime startOfDay = DateTime(date.year, date.month, date.day);
        final DateTime endOfDay =
            DateTime(date.year, date.month, date.day, 23, 59, 59);

        final List<HealthDataPoint> healthData =
            await health.getHealthDataFromTypes(
          types: <HealthDataType>[HealthDataType.STEPS],
          startTime: startOfDay,
          endTime: endOfDay,
        );

        int daySteps = 0;
        for (final HealthDataPoint point in healthData) {
          if (point.value is int) {
            daySteps += point.value as int;
          }
        }

        weeklySteps.add(DailySteps(date: startOfDay, steps: daySteps));
      }

      return weeklySteps;
    } catch (e) {
      return <DailySteps>[];
    }
  }

  Future<List<int>> getWeeklyStepTotals() async {
    final List<DailySteps> entries = await getWeeklySteps();
    if (entries.length == 7) {
      return entries.map((DailySteps e) => e.steps).toList();
    }

    final List<int> fallback = <int>[4200, 7800, 6100, 9200, 5500, 8900, 7342];
    return fallback;
  }

  Future<List<HealthDataPoint>> getHeartRateSamples() async {
    try {
      final DateTime now = DateTime.now();
      final DateTime oneDayAgo = now.subtract(const Duration(hours: 24));

      final List<HealthDataPoint> healthData =
          await health.getHealthDataFromTypes(
        types: <HealthDataType>[HealthDataType.HEART_RATE],
        startTime: oneDayAgo,
        endTime: now,
      );

      return healthData;
    } catch (e) {
      return <HealthDataPoint>[];
    }
  }

  Future<bool> isGoogleFitAvailable() async {
    try {
      if (Platform.isAndroid) {
        return true; // TODO: Check actual availability
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

enum ActivityStatus { idle, walking, running }
