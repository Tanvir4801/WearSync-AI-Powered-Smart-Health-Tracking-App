import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../firebase/auth_service.dart';
import '../../../firebase/health_repository.dart';
import '../../../firebase/models/health_data.dart';

part 'profile_provider.g.dart';

class ProfileState {
  const ProfileState({
    required this.dailyStepGoal,
    required this.demoMode,
    required this.notificationsEnabled,
    required this.waterReminder,
    required this.stepUnit,
  });

  final int dailyStepGoal;
  final bool demoMode;
  final bool notificationsEnabled;
  final int waterReminder;
  final StepUnit stepUnit;

  ProfileState copyWith({
    int? dailyStepGoal,
    bool? demoMode,
    bool? notificationsEnabled,
    int? waterReminder,
    StepUnit? stepUnit,
  }) {
    return ProfileState(
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      demoMode: demoMode ?? this.demoMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      waterReminder: waterReminder ?? this.waterReminder,
      stepUnit: stepUnit ?? this.stepUnit,
    );
  }
}

enum StepUnit { steps, km }

class WeeklySummaryData {
  const WeeklySummaryData({
    required this.avgDailySteps,
    required this.activeDays,
    required this.bestDay,
    required this.totalSteps,
    required this.dailySteps,
  });

  final int avgDailySteps;
  final int activeDays;
  final int bestDay;
  final int totalSteps;
  final List<int> dailySteps;
}

class UserProfileInfo {
  const UserProfileInfo({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.memberSince,
    this.age,
    this.weightKg,
    this.heightCm,
  });

  final String displayName;
  final String email;
  final String photoUrl;
  final DateTime memberSince;
  final int? age;
  final double? weightKg;
  final double? heightCm;
}

class AchievementStatus {
  const AchievementStatus({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.unlocked,
    this.earnedAt,
  });

  final String id;
  final String name;
  final String emoji;
  final String description;
  final bool unlocked;
  final DateTime? earnedAt;
}

class _AchievementDefinition {
  const _AchievementDefinition({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
  });

  final String id;
  final String name;
  final String emoji;
  final String description;
}

const List<_AchievementDefinition> _achievementDefinitions =
    <_AchievementDefinition>[
  _AchievementDefinition(
    id: 'first_steps',
    name: 'First Steps',
    emoji: '🥾',
    description: 'You logged your very first steps.',
  ),
  _AchievementDefinition(
    id: 'goal_crusher',
    name: 'Goal Crusher',
    emoji: '🏆',
    description: 'You reached your daily goal at least once.',
  ),
  _AchievementDefinition(
    id: 'week_warrior',
    name: 'Week Warrior',
    emoji: '🔥',
    description: 'You stayed active for 7 days in a row.',
  ),
  _AchievementDefinition(
    id: 'hydration_hero',
    name: 'Hydration Hero',
    emoji: '💧',
    description: 'You logged 8 glasses of water in one day.',
  ),
  _AchievementDefinition(
    id: 'early_bird',
    name: 'Early Bird',
    emoji: '🌅',
    description: 'You logged steps before 8:00 AM.',
  ),
  _AchievementDefinition(
    id: 'ten_k_club',
    name: '10K Club',
    emoji: '⭐',
    description: 'You hit 10,000 steps in a day.',
  ),
];

@riverpod
AuthService authService(Ref ref) => AuthService();

@riverpod
HealthRepository healthRepository(Ref ref) => HealthRepository();

@riverpod
Future<List<HealthData>> weekHealthData(Ref ref) async {
  final AuthService auth = ref.read(authServiceProvider);
  final String? uid = auth.currentUser?.uid;

  if (uid == null) {
    return <HealthData>[];
  }

  final DateTime sevenDaysAgo =
      DateTime.now().subtract(const Duration(days: 7));
  final String dateFilter = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);

  try {
    final QuerySnapshot<Map<String, dynamic>> docs = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(uid)
        .collection('health')
        .where('date', isGreaterThanOrEqualTo: dateFilter)
        .get();

    return docs.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data();
      return HealthData(
        steps: (data['steps'] as num?)?.toInt() ?? 0,
        calories: (data['calories'] as num?)?.toInt() ?? 0,
        heartRateAvg: (data['heartRate'] as num?)?.toInt() ?? 0,
        activeMinutes: (data['activeMinutes'] as num?)?.toInt() ?? 0,
        waterGlasses:
            ((data['water'] ?? data['waterGlasses']) as num?)?.toInt() ?? 0,
        createdAt: _toDateTime(data['createdAt']) ?? DateTime.now(),
        updatedAt: _toDateTime(data['updatedAt']) ?? DateTime.now(),
      );
    }).toList();
  } on FirebaseException catch (error) {
    if (_isFirestoreUnavailable(error)) {
      return <HealthData>[];
    }
    rethrow;
  }
}

final FutureProvider<UserProfileInfo> userProfileInfoProvider =
    FutureProvider<UserProfileInfo>((Ref ref) async {
  final AuthService auth = ref.read(authServiceProvider);
  final String? uid = auth.currentUser?.uid;

  if (uid == null) {
    return UserProfileInfo(
      displayName: 'User',
      email: '',
      photoUrl: '',
      memberSince: DateTime(2026, 4, 1),
    );
  }

  final Map<String, dynamic> data;
  try {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    data = doc.data() ?? <String, dynamic>{};
  } on FirebaseException catch (error) {
    if (_isFirestoreUnavailable(error)) {
      return UserProfileInfo(
        displayName: auth.currentUser?.displayName ?? 'User',
        email: auth.currentUser?.email ?? '',
        photoUrl: '',
        memberSince: DateTime(2026, 4, 1),
      );
    }
    rethrow;
  }

  return UserProfileInfo(
    displayName: (data['displayName'] as String?)?.trim().isNotEmpty == true
        ? data['displayName'] as String
        : (auth.currentUser?.displayName ?? 'User'),
    email: (data['email'] as String?) ?? (auth.currentUser?.email ?? ''),
    photoUrl: (data['photoURL'] as String?) ?? '',
    memberSince: _toDateTime(data['createdAt']) ?? DateTime(2026, 4, 1),
    age: (data['age'] as num?)?.toInt(),
    weightKg: (data['weightKg'] as num?)?.toDouble(),
    heightCm: (data['heightCm'] as num?)?.toDouble(),
  );
});

final FutureProvider<WeeklySummaryData> weeklySummaryProvider =
    FutureProvider<WeeklySummaryData>((Ref ref) async {
  final AuthService auth = ref.read(authServiceProvider);
  final String? uid = auth.currentUser?.uid;
  final bool demoMode = ref.watch(profileControllerProvider).demoMode;

  if (uid == null) {
    return const WeeklySummaryData(
      avgDailySteps: 0,
      activeDays: 0,
      bestDay: 0,
      totalSteps: 0,
      dailySteps: <int>[0, 0, 0, 0, 0, 0, 0],
    );
  }

  final DateTime now = DateTime.now();
  final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
  final String filter = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);

  final QuerySnapshot<Map<String, dynamic>> docs = await FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('health')
      .where('date', isGreaterThanOrEqualTo: filter)
      .get();

  final Map<String, int> byDate = <String, int>{};
  final List<int> stepsList =
      docs.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final Map<String, dynamic> data = d.data();
    final int steps = (data['steps'] as num?)?.toInt() ?? 0;
    final String key = (data['date'] as String?) ?? d.id;
    byDate[key] = steps;
    return steps;
  }).toList();

  if (stepsList.isEmpty && demoMode) {
    return const WeeklySummaryData(
      avgDailySteps: 6840,
      activeDays: 5,
      bestDay: 9200,
      totalSteps: 47880,
      dailySteps: <int>[5600, 6100, 7200, 9200, 4900, 7600, 7280],
    );
  }

  final List<int> daily = List<int>.generate(7, (int index) {
    final DateTime day = now.subtract(Duration(days: 6 - index));
    final String dayKey = DateFormat('yyyy-MM-dd').format(day);
    return byDate[dayKey] ?? 0;
  });

  final int avgDailySteps = stepsList.isEmpty
      ? 0
      : (stepsList.reduce((int a, int b) => a + b) / stepsList.length).round();
  final int activeDays = stepsList.where((int s) => s > 500).length;
  final int bestDay = stepsList.isEmpty ? 0 : stepsList.reduce(max);
  final int totalSteps = daily.fold<int>(0, (int sum, int v) => sum + v);

  unawaited(() async {
    try {
      await _awardAchievementsIfNeeded(
        uid: uid,
        dailyGoal: ref.watch(profileControllerProvider).dailyStepGoal,
        healthDocs: docs.docs,
      );
    } on FirebaseException catch (error) {
      if (!_isFirestoreUnavailable(error)) {
        rethrow;
      }
    }
  }());

  return WeeklySummaryData(
    avgDailySteps: avgDailySteps,
    activeDays: activeDays,
    bestDay: bestDay,
    totalSteps: totalSteps,
    dailySteps: daily,
  );
});

final FutureProvider<List<AchievementStatus>> achievementsProvider =
    FutureProvider<List<AchievementStatus>>((Ref ref) async {
  final AuthService auth = ref.read(authServiceProvider);
  final String? uid = auth.currentUser?.uid;
  if (uid == null) {
    return _achievementDefinitions
        .map((d) => AchievementStatus(
              id: d.id,
              name: d.name,
              emoji: d.emoji,
              description: d.description,
              unlocked: false,
            ))
        .toList();
  }

  final QuerySnapshot<Map<String, dynamic>> docs;
  try {
    docs = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('achievements')
        .get();
  } on FirebaseException catch (error) {
    if (_isFirestoreUnavailable(error)) {
      return _achievementDefinitions
          .map((d) => AchievementStatus(
                id: d.id,
                name: d.name,
                emoji: d.emoji,
                description: d.description,
                unlocked: false,
              ))
          .toList();
    }
    rethrow;
  }
  final Map<String, Map<String, dynamic>> earned =
      <String, Map<String, dynamic>>{
    for (final QueryDocumentSnapshot<Map<String, dynamic>> d in docs.docs)
      d.id: d.data(),
  };

  return _achievementDefinitions.map((def) {
    final Map<String, dynamic>? data = earned[def.id];
    return AchievementStatus(
      id: def.id,
      name: def.name,
      emoji: def.emoji,
      description: def.description,
      unlocked: data != null,
      earnedAt: data == null ? null : _toDateTime(data['earnedAt']),
    );
  }).toList();
});

@riverpod
class ProfileController extends _$ProfileController {
  @override
  ProfileState build() {
    unawaited(_loadSettings());
    return const ProfileState(
      dailyStepGoal: 10000,
      demoMode: false,
      notificationsEnabled: true,
      waterReminder: 60,
      stepUnit: StepUnit.steps,
    );
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      dailyStepGoal: prefs.getInt('daily_step_goal') ?? state.dailyStepGoal,
      demoMode: prefs.getBool('demo_mode') ?? state.demoMode,
      notificationsEnabled:
          prefs.getBool('notifications_enabled') ?? state.notificationsEnabled,
      waterReminder: prefs.getInt('water_reminder') ?? state.waterReminder,
      stepUnit: (prefs.getString('step_unit') ?? 'steps') == 'km'
          ? StepUnit.km
          : StepUnit.steps,
    );
  }

  void setDailyGoal(int goal) {
    final int clamped = goal.clamp(1000, 50000);
    state = state.copyWith(dailyStepGoal: clamped);
    unawaited(_saveInt('daily_step_goal', clamped));
  }

  void setDemoMode(bool enabled) {
    state = state.copyWith(demoMode: enabled);
    unawaited(_saveBool('demo_mode', enabled));
  }

  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    unawaited(_saveBool('notifications_enabled', enabled));
  }

  void setWaterReminder(int minutes) {
    state = state.copyWith(waterReminder: minutes);
    unawaited(_saveInt('water_reminder', minutes));
  }

  void setStepUnit(StepUnit unit) {
    state = state.copyWith(stepUnit: unit);
    unawaited(_saveString('step_unit', unit.name));
  }

  Future<void> _saveBool(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}

Future<void> _awardAchievementsIfNeeded({
  required String uid,
  required int dailyGoal,
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> healthDocs,
}) async {
  try {
    final CollectionReference<Map<String, dynamic>> achRef = FirebaseFirestore
        .instance
        .collection('users')
        .doc(uid)
        .collection('achievements');

    final QuerySnapshot<Map<String, dynamic>> existingSnapshot =
        await achRef.get();
    final Set<String> existing = existingSnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.id)
        .toSet();

    final List<Map<String, dynamic>> health = healthDocs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.data())
        .toList();
    final int totalSteps = health.fold<int>(
        0,
        (int sum, Map<String, dynamic> d) =>
            sum + ((d['steps'] as num?)?.toInt() ?? 0));
    final bool hasGoalCrusher = health.any((Map<String, dynamic> d) =>
        ((d['steps'] as num?)?.toInt() ?? 0) >= dailyGoal);
    final bool hasTenK = health.any((Map<String, dynamic> d) =>
        ((d['steps'] as num?)?.toInt() ?? 0) >= 10000);
    final bool hasHydration = health.any((Map<String, dynamic> d) {
      final num? water = (d['water'] ?? d['waterGlasses']) as num?;
      return (water?.toInt() ?? 0) >= 8;
    });

    final bool hasEarlyBird = health.any((Map<String, dynamic> d) {
      final int steps = (d['steps'] as num?)?.toInt() ?? 0;
      final DateTime? dt =
          _toDateTime(d['updatedAt']) ?? _toDateTime(d['createdAt']);
      return steps > 0 && dt != null && dt.hour < 8;
    });

    final Map<String, bool> activeByDate = <String, bool>{
      for (final Map<String, dynamic> d in health)
        if (d['date'] is String)
          d['date'] as String: ((d['steps'] as num?)?.toInt() ?? 0) > 500,
    };
    bool weekWarrior = true;
    for (int i = 0; i < 7; i++) {
      final DateTime day = DateTime.now().subtract(Duration(days: i));
      final String key = DateFormat('yyyy-MM-dd').format(day);
      if (!(activeByDate[key] ?? false)) {
        weekWarrior = false;
        break;
      }
    }

    final Map<String, bool> unlockedRules = <String, bool>{
      'first_steps': totalSteps > 0,
      'goal_crusher': hasGoalCrusher,
      'week_warrior': weekWarrior,
      'hydration_hero': hasHydration,
      'early_bird': hasEarlyBird,
      'ten_k_club': hasTenK,
    };

    final WriteBatch batch = FirebaseFirestore.instance.batch();
    bool hasWrites = false;
    for (final _AchievementDefinition def in _achievementDefinitions) {
      if ((unlockedRules[def.id] ?? false) && !existing.contains(def.id)) {
        hasWrites = true;
        batch.set(achRef.doc(def.id), <String, dynamic>{
          'earnedAt': FieldValue.serverTimestamp(),
        });
      }
    }
    if (hasWrites) {
      await batch.commit();
    }
  } on FirebaseException catch (error) {
    if (!_isFirestoreUnavailable(error)) {
      rethrow;
    }
  }
}

bool _isFirestoreUnavailable(FirebaseException error) {
  return error.code == 'unavailable' ||
      error.code == 'deadline-exceeded' ||
      error.code == 'network-request-failed';
}

DateTime? _toDateTime(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return null;
}
