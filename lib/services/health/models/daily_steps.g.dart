// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_steps.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyStepsImpl _$$DailyStepsImplFromJson(Map<String, dynamic> json) =>
    _$DailyStepsImpl(
      date: DateTime.parse(json['date'] as String),
      steps: (json['steps'] as num).toInt(),
    );

Map<String, dynamic> _$$DailyStepsImplToJson(_$DailyStepsImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'steps': instance.steps,
    };
