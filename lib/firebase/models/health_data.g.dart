// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthDataImpl _$$HealthDataImplFromJson(Map<String, dynamic> json) =>
    _$HealthDataImpl(
      steps: (json['steps'] as num).toInt(),
      calories: (json['calories'] as num).toInt(),
      heartRateAvg: (json['heartRateAvg'] as num).toInt(),
      activeMinutes: (json['activeMinutes'] as num).toInt(),
      waterGlasses: (json['waterGlasses'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$HealthDataImplToJson(_$HealthDataImpl instance) =>
    <String, dynamic>{
      'steps': instance.steps,
      'calories': instance.calories,
      'heartRateAvg': instance.heartRateAvg,
      'activeMinutes': instance.activeMinutes,
      'waterGlasses': instance.waterGlasses,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
