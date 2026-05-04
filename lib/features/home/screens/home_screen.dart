import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../services/health/health_service.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  bool _isInsightDismissed = false;
  int _waterGlasses = 0;

  static const int _dailyWaterGoal = 8;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    unawaited(_loadWaterForToday());
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeState state = ref.watch(homeControllerProvider);
    final _InsightMeta insight = _insightMeta(state);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _section(
                  index: 0, child: _TopSection(dateText: _formattedDate())),
              const SizedBox(height: 24),
              _section(
                index: 1,
                child: _HeroStepsRing(
                  todaySteps: state.todaySteps,
                  dailyGoal: state.dailyGoal,
                ),
              ),
              const SizedBox(height: 24),
              _section(index: 2, child: _StatsGrid(state: state)),
              const SizedBox(height: 20),
              if (!_isInsightDismissed)
                _section(
                  index: 3,
                  child: GestureDetector(
                    onTap: () => setState(() => _isInsightDismissed = true),
                    child: GlassmorphismCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(insight.icon, color: AppTheme.warning),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              insight.text,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (!_isInsightDismissed) const SizedBox(height: 20),
              _section(
                index: 4,
                child: _QuickActionsRow(
                  waterGlasses: _waterGlasses,
                  dailyGoal: _dailyWaterGoal,
                  onLogWater: _logWater,
                  onStartWorkout: _openWorkoutSelector,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({required int index, required Widget child}) {
    final int startMs = index * 100;
    final double begin = (startMs / 900).clamp(0, 1).toDouble();
    final double end = ((startMs + 500) / 900).clamp(0, 1).toDouble();

    final Animation<double> fade = CurvedAnimation(
      parent: _introController,
      curve: Interval(begin, end, curve: Curves.easeOut),
    );
    final Animation<Offset> slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }

  String _formattedDate() {
    const List<String> weekdays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final DateTime now = DateTime.now();
    final String weekday = weekdays[now.weekday - 1];
    final String month = months[now.month - 1];
    return '$weekday, $month ${now.day}';
  }

  Future<void> _loadWaterForToday() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int count = prefs.getInt(_waterKeyForDate(DateTime.now())) ?? 0;
    if (!mounted) {
      return;
    }
    setState(() => _waterGlasses = count);
  }

  Future<void> _logWater() async {
    final int nextCount = _waterGlasses + 1;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_waterKeyForDate(DateTime.now()), nextCount);

    if (!mounted) {
      return;
    }

    setState(() => _waterGlasses = nextCount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '💧 Water logged! $_waterGlasses/$_dailyWaterGoal glasses today'),
      ),
    );

    await _saveWaterToFirestore(nextCount);
  }

  Future<void> _saveWaterToFirestore(int count) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }

    final DateTime now = DateTime.now();
    final String dateId =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('health')
        .doc(dateId)
        .set(<String, dynamic>{
      'waterGlasses': count,
      'updatedAt': Timestamp.fromDate(now),
      'createdAt': Timestamp.fromDate(now),
    }, SetOptions(merge: true));
  }

  Future<void> _openWorkoutSelector() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _workouts.length,
            itemBuilder: (BuildContext context, int index) {
              final _WorkoutOption option = _workouts[index];
              return ListTile(
                leading: Icon(option.icon, color: AppTheme.secondaryAccent),
                title: Text('${option.label} ${option.emoji}'),
                subtitle: Text('${option.caloriesPerHour} kcal/hour'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(this.context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => WorkoutTimerScreen(option: option),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String _waterKeyForDate(DateTime date) {
    return 'water_glasses_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  _InsightMeta _insightMeta(HomeState state) {
    final int hour = DateTime.now().hour;

    if (state.todaySteps >= state.dailyGoal) {
      return const _InsightMeta(
        text: "Goal crushed! You're amazing today 🏆",
        icon: Icons.emoji_events_rounded,
      );
    }
    if (state.todaySteps >= (state.dailyGoal * 0.8).round()) {
      return _InsightMeta(
        text:
            'Almost there! Just ${state.dailyGoal - state.todaySteps} steps to go',
        icon: Icons.lightbulb_rounded,
      );
    }
    if (hour >= 20 && state.todaySteps < (state.dailyGoal * 0.5).round()) {
      return _InsightMeta(
        text: 'Evening reminder: only ${state.todaySteps} steps so far today',
        icon: Icons.lightbulb_rounded,
      );
    }
    if (hour < 10 && state.todaySteps < 500) {
      return const _InsightMeta(
        text: "Great day ahead — let's start moving!",
        icon: Icons.lightbulb_rounded,
      );
    }
    if (state.activityStatus == ActivityStatus.running) {
      return const _InsightMeta(
        text: "You're on fire! Keep that pace 🔥",
        icon: Icons.local_fire_department_rounded,
      );
    }
    if (state.activityStatus == ActivityStatus.walking) {
      return const _InsightMeta(
        text: 'Nice walk! Every step counts 👟',
        icon: Icons.directions_walk_rounded,
      );
    }
    return _InsightMeta(
      text: "You've taken ${state.todaySteps} steps — keep going!",
      icon: Icons.lightbulb_rounded,
    );
  }
}

class _TopSection extends StatelessWidget {
  const _TopSection({required this.dateText});

  final String dateText;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final User? user = FirebaseAuth.instance.currentUser;
    final String name = user?.displayName?.split(' ').first ?? 'there';
    final int hour = DateTime.now().hour;
    final String greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$greeting, $name',
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dateText,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.card,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            (name.isNotEmpty ? name[0] : 'U').toUpperCase(),
            style: textTheme.labelLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroStepsRing extends StatelessWidget {
  const _HeroStepsRing({
    required this.todaySteps,
    required this.dailyGoal,
  });

  final int todaySteps;
  final int dailyGoal;

  @override
  Widget build(BuildContext context) {
    final double progress =
        dailyGoal <= 0 ? 0 : (todaySteps / dailyGoal).clamp(0, 1).toDouble();

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double value, Widget? child) {
          return SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(
              painter: StepRingPainter(
                progress: value,
                trackColor: const Color(0xFF1E293B),
                progressGradient: const LinearGradient(
                  colors: <Color>[Color(0xFF6366F1), Color(0xFF22D3EE)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '$todaySteps',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$dailyGoal goal',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class StepRingPainter extends CustomPainter {
  const StepRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressGradient,
  });

  final double progress;
  final Color trackColor;
  final Gradient progressGradient;

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 12;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width / 2) - strokeWidth / 2;
    const double startAngle = -math.pi / 2;
    final double sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint gradientPaint = Paint()
      ..shader = progressGradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, gradientPaint);
  }

  @override
  bool shouldRepaint(StepRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final double progress =
        (state.todaySteps / state.dailyGoal).clamp(0.0, 1.0).toDouble();
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: _MetricCard(
                icon: Icons.directions_walk_rounded,
                iconColor: const Color(0xFF22D3EE),
                value: '${(progress * 100).round()}%',
                unit: '${state.todaySteps}/${state.dailyGoal}',
                label: 'Steps Progress',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HeartRateCard(
                bpm: state.heartRate,
                trend: state.heartRateTrend,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _MetricCard(
                icon: Icons.local_fire_department,
                iconColor: const Color(0xFFF59E0B),
                value: '${state.calories}',
                unit: 'kcal',
                label: 'Calories',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.route_rounded,
                iconColor: const Color(0xFF6366F1),
                value: state.distanceFormatted,
                unit: 'Distance',
                label: 'Distance',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.unit,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.15),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartRateCard extends StatelessWidget {
  const _HeartRateCard({required this.bpm, required this.trend});

  final int bpm;
  final List<int> trend;

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.error.withValues(alpha: 0.16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.favorite, color: AppTheme.error, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            '$bpm',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
          ),
          const Text(
            'bpm',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            width: double.infinity,
            child: CustomPaint(
              painter: _HeartSparklinePainter(points: trend),
            ),
          ),
          const Text(
            'Heart Rate',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _HeartSparklinePainter extends CustomPainter {
  const _HeartSparklinePainter({required this.points});

  final List<int> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }

    final int minVal = points.reduce(math.min);
    final int maxVal = points.reduce(math.max);
    final double spread = math.max(1, maxVal - minVal).toDouble();

    final Paint linePaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint dotPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    final Path path = Path();
    for (int i = 0; i < points.length; i++) {
      final double x =
          points.length == 1 ? 0 : (i / (points.length - 1)) * size.width;
      final double y =
          size.height - ((points[i] - minVal) / spread * (size.height - 6)) - 3;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    for (int i = 0; i < points.length; i++) {
      final double x =
          points.length == 1 ? 0 : (i / (points.length - 1)) * size.width;
      final double y =
          size.height - ((points[i] - minVal) / spread * (size.height - 6)) - 3;
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_HeartSparklinePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.waterGlasses,
    required this.dailyGoal,
    required this.onLogWater,
    required this.onStartWorkout,
  });

  final int waterGlasses;
  final int dailyGoal;
  final VoidCallback onLogWater;
  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _ActionCard(
            icon: Icons.water_drop_outlined,
            title: 'Log Water',
            subtitle: '💧 $waterGlasses/$dailyGoal',
            footer: waterGlasses >= dailyGoal ? 'Goal reached!' : null,
            onTap: onLogWater,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.play_circle_outline,
            title: 'Start Workout',
            subtitle: 'Choose activity',
            onTap: onStartWorkout,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.footer,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphismCard(
        child: SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: AppTheme.secondaryAccent),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (footer != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Color(0xFF22C55E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            footer!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightMeta {
  const _InsightMeta({required this.text, required this.icon});

  final String text;
  final IconData icon;
}

class _WorkoutOption {
  const _WorkoutOption({
    required this.label,
    required this.emoji,
    required this.icon,
    required this.caloriesPerHour,
  });

  final String label;
  final String emoji;
  final IconData icon;
  final int caloriesPerHour;
}

const List<_WorkoutOption> _workouts = <_WorkoutOption>[
  _WorkoutOption(
    label: 'Walking',
    emoji: '🚶',
    icon: Icons.directions_walk_rounded,
    caloriesPerHour: 220,
  ),
  _WorkoutOption(
    label: 'Running',
    emoji: '🏃',
    icon: Icons.directions_run_rounded,
    caloriesPerHour: 520,
  ),
  _WorkoutOption(
    label: 'Cycling',
    emoji: '🚴',
    icon: Icons.pedal_bike_rounded,
    caloriesPerHour: 450,
  ),
  _WorkoutOption(
    label: 'Yoga',
    emoji: '🧘',
    icon: Icons.self_improvement_rounded,
    caloriesPerHour: 180,
  ),
  _WorkoutOption(
    label: 'Gym',
    emoji: '💪',
    icon: Icons.fitness_center_rounded,
    caloriesPerHour: 400,
  ),
];

class WorkoutTimerScreen extends StatefulWidget {
  const WorkoutTimerScreen({super.key, required this.option});

  final _WorkoutOption option;

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  late final DateTime _startTime;
  late final Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _elapsed = DateTime.now().difference(_startTime);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(widget.option.label)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(widget.option.emoji, style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 12),
              Text(
                _formatDuration(_elapsed),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _stopWorkout,
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Stop Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _stopWorkout() async {
    _timer.cancel();
    final int durationMinutes = _elapsed.inMinutes;
    final int estimatedCalories =
        ((widget.option.caloriesPerHour / 60) * durationMinutes).round();
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final String workoutId = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance
          .collection('workouts')
          .doc(uid)
          .collection('sessions')
          .doc(workoutId)
          .set(<String, dynamic>{
        'type': widget.option.label,
        'durationMinutes': durationMinutes,
        'startTime': Timestamp.fromDate(_startTime),
        'estimatedCalories': estimatedCalories,
      });
    }

    if (!mounted) {
      return;
    }

    final String message;
    if (durationMinutes >= 30) {
      message = 'Awesome effort! You just completed a strong session 💪';
    } else if (durationMinutes >= 10) {
      message = 'Great consistency! Every workout makes you stronger.';
    } else {
      message = 'Nice start! Keep building the habit one session at a time.';
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pop();
  }

  String _formatDuration(Duration value) {
    final String h = value.inHours.toString().padLeft(2, '0');
    final String m = (value.inMinutes % 60).toString().padLeft(2, '0');
    final String s = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
