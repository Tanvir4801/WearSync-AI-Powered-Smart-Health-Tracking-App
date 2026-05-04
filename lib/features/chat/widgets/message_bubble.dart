import 'package:flutter/material.dart';

String _formatTime(DateTime time) {
  final String h = time.hour.toString().padLeft(2, '0');
  final String m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class UserBubble extends StatelessWidget {
  const UserBubble({super.key, required this.message, required this.timestamp});

  final String message;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF6366F1), Color(0xFF22D3EE)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class AiBubble extends StatelessWidget {
  const AiBubble({
    super.key,
    required this.message,
    required this.timestamp,
    this.isError = false,
  });

  final String message;
  final DateTime timestamp;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6366F1),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      border: Border.all(
                        color: isError
                            ? const Color(0xFFF87171)
                            : const Color(0xFF334155).withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: isError
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 16,
                                color: Color(0xFFF87171),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  message,
                                  style: const TextStyle(
                                    color: Color(0xFFFCA5A5),
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            message,
                            style: const TextStyle(
                              color: Color(0xFFF1F5F9),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                _formatTime(timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
