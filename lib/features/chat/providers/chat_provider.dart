import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/chat_message.dart';
import '../services/ai_service.dart';

part 'chat_provider.g.dart';

class ChatState {
  const ChatState({
    required this.messages,
    required this.isLoading,
    this.errorMessage,
  });

  const ChatState.initial()
      : messages = const <ChatMessage>[],
        isLoading = false,
        errorMessage = null;

  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
class ChatController extends _$ChatController {
  late final AiService _aiService;

  static const String _initialGreeting =
      "Hi! I'm SmartWear AI 👋 I can help with fitness tips, diet advice, and reading your health data. What would you like to know?";

  @override
  ChatState build() {
    _aiService = AiService();
    return ChatState(
      messages: <ChatMessage>[
        ChatMessage(
          role: ChatRole.assistant,
          content: _initialGreeting,
          timestamp: DateTime.now(),
        ),
      ],
      isLoading: false,
    );
  }

  Future<void> sendMessage(String userMessage) async {
    final String trimmedMessage = userMessage.trim();
    if (trimmedMessage.isEmpty) {
      return;
    }

    final List<Map<String, String>> historyForApi = state.messages
        .where((ChatMessage m) => m.role != ChatRole.system)
        .map((ChatMessage m) => <String, String>{
              'role': m.role.name,
              'content': m.content,
            })
        .toList();

    // Add user message to list
    final DateTime now = DateTime.now();
    final ChatMessage userMsg = ChatMessage(
      role: ChatRole.user,
      content: trimmedMessage,
      timestamp: now,
    );

    state = state.copyWith(
      messages: <ChatMessage>[...state.messages, userMsg],
      isLoading: true,
      clearError: true,
    );

    try {
      final String aiResponse =
          await _aiService.sendMessage(historyForApi, trimmedMessage);

      // Add AI response to list
      final ChatMessage aiMsg = ChatMessage(
        role: ChatRole.assistant,
        content: aiResponse,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: <ChatMessage>[...state.messages, aiMsg],
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  void clearMessages() {
    state = ChatState(
      messages: <ChatMessage>[
        ChatMessage(
          role: ChatRole.assistant,
          content: _initialGreeting,
          timestamp: DateTime.now(),
        ),
      ],
      isLoading: false,
    );
  }
}
