// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivitySessionImpl _$$ActivitySessionImplFromJson(
        Map<String, dynamic> json) =>
    _$ActivitySessionImpl(
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      duration: (json['duration'] as num).toInt(),
      steps: (json['steps'] as num).toInt(),
      startTime: DateTime.parse(json['startTime'] as String),
    );

Map<String, dynamic> _$$ActivitySessionImplToJson(
        _$ActivitySessionImpl instance) =>
    <String, dynamic>{
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'duration': instance.duration,
      'steps': instance.steps,
      'startTime': instance.startTime.toIso8601String(),
    };

const _$ActivityTypeEnumMap = {
  ActivityType.walk: 'walk',
  ActivityType.run: 'run',
};
