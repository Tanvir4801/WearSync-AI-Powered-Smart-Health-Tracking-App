import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_session.freezed.dart';
part 'activity_session.g.dart';

enum ActivityType { walk, run }

@freezed
class ActivitySession with _$ActivitySession {
  const factory ActivitySession({
    required ActivityType type,
    required int duration,
    required int steps,
    required DateTime startTime,
  }) = _ActivitySession;

  factory ActivitySession.fromJson(Map<String, dynamic> json) =>
      _$ActivitySessionFromJson(json);
}
