import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_steps.freezed.dart';
part 'daily_steps.g.dart';

@freezed
class DailySteps with _$DailySteps {
  const factory DailySteps({
    required DateTime date,
    required int steps,
  }) = _DailySteps;

  factory DailySteps.fromJson(Map<String, dynamic> json) =>
      _$DailyStepsFromJson(json);
}
