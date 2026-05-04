// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      role: $enumDecode(_$ChatRoleEnumMap, json['role']),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'role': _$ChatRoleEnumMap[instance.role]!,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$ChatRoleEnumMap = {
  ChatRole.user: 'user',
  ChatRole.assistant: 'assistant',
  ChatRole.system: 'system',
};
