import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_data.freezed.dart';
part 'health_data.g.dart';

@freezed
class HealthData with _$HealthData {
  const factory HealthData({
    required int steps,
    required int calories,
    required int heartRateAvg,
    required int activeMinutes,
    required int waterGlasses,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _HealthData;

  factory HealthData.fromJson(Map<String, dynamic> json) =>
      _$HealthDataFromJson(json);
}
