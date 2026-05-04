import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum ChatRole { user, assistant, system }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required ChatRole role,
    required String content,
    required DateTime timestamp,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
