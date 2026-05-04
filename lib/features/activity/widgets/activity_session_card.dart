import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../models/activity_session.dart';

class ActivitySessionCard extends StatefulWidget {
  const ActivitySessionCard({
    super.key,
    required this.session,
    this.isActive = false,
  });

  final ActivitySession session;
  final bool isActive;

  @override
  State<ActivitySessionCard> createState() => _ActivitySessionCardState();
}

class _ActivitySessionCardState extends State<ActivitySessionCard> {
  static const Duration _pressDuration = Duration(milliseconds: 140);
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final ActivitySession session = widget.session;
    final bool isRun = session.type == ActivityType.run;
    final Color accent = isRun ? AppTheme.secondaryAccent : AppTheme.primaryAccent;
    final double glowOpacity = widget.isActive ? 0.22 : 0.06;
    final double glowBlur = widget.isActive ? 28 : 14;
    final double scale = _pressed ? 0.98 : 1;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        duration: _pressDuration,
        curve: Curves.easeOutCubic,
        scale: scale,
        child: GlassmorphismCard(
          padding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border(
                left: BorderSide(color: accent, width: 4),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(alpha: glowOpacity),
                  blurRadius: glowBlur,
                  spreadRadius: widget.isActive ? 1.5 : 0,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.14),
                  ),
                  child: Icon(
                    isRun ? Icons.directions_run : Icons.directions_walk,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        isRun ? 'Running Session' : 'Walking Session',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${session.duration} min  •  ${session.steps} steps',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _timeLabel(session.startTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _timeLabel(DateTime time) {
    final int h = time.hour;
    final int displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final String minute = time.minute.toString().padLeft(2, '0');
    final String suffix = h >= 12 ? 'PM' : 'AM';
    return '$displayHour:$minute $suffix';
  }
}
