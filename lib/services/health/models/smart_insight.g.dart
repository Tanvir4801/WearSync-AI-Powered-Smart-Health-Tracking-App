// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_insight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SmartInsightImpl _$$SmartInsightImplFromJson(Map<String, dynamic> json) =>
    _$SmartInsightImpl(
      headline: json['headline'] as String,
      detail: json['detail'] as String,
      suggestion: json['suggestion'] as String,
      type: $enumDecode(_$SmartInsightTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$SmartInsightImplToJson(_$SmartInsightImpl instance) =>
    <String, dynamic>{
      'headline': instance.headline,
      'detail': instance.detail,
      'suggestion': instance.suggestion,
      'type': _$SmartInsightTypeEnumMap[instance.type]!,
    };

const _$SmartInsightTypeEnumMap = {
  SmartInsightType.positive: 'positive',
  SmartInsightType.warning: 'warning',
  SmartInsightType.tip: 'tip',
};
