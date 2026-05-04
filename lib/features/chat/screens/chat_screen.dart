import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  static const List<String> suggestedQuestions = <String>[
    'How many steps should I walk?',
    'Best post-workout meal?',
    'Am I active enough today?',
    'How to improve sleep?',
  ];

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showQuickQuestions = true;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatState chatState = ref.watch(chatControllerProvider);
    final ChatController chatNotifier =
        ref.read(chatControllerProvider.notifier);

    ref.listen<ChatState>(chatControllerProvider,
        (ChatState? previous, ChatState next) {
      final bool messageCountChanged =
          previous?.messages.length != next.messages.length;
      final bool loadingChanged = previous?.isLoading != next.isLoading;
      if (!messageCountChanged && !loadingChanged) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leadingWidth: 28,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: _AppBarStatusDot(isLoading: chatState.isLoading),
          ),
        ),
        titleSpacing: 8,
        title: const Row(
          children: <Widget>[
            _AppBarAvatar(),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'SmartWear AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Fitness & Diet Assistant',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Clear chat',
            onPressed: () => _confirmClearChat(chatNotifier),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppTheme.background,
              AppTheme.background.withValues(alpha: 0.95),
              const Color(0xFF101B33),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      AppTheme.primaryAccent.withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: -100,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      AppTheme.secondaryAccent.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: chatState.messages.length +
                          (chatState.isLoading ? 1 : 0),
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0 && chatState.isLoading) {
                          return const TypingIndicatorBubble();
                        }

                        final int msgIndex =
                            chatState.isLoading ? index - 1 : index;
                        final ChatMessage msg = chatState
                            .messages[chatState.messages.length - 1 - msgIndex];

                        final bool isError = _isAiErrorMessage(msg.content);

                        return AnimatedSlide(
                          offset: const Offset(0, 0.03),
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: Align(
                            alignment: msg.role == ChatRole.user
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: msg.role == ChatRole.user
                                ? UserBubble(
                                    message: msg.content,
                                    timestamp: msg.timestamp,
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      AiBubble(
                                        message: msg.content,
                                        timestamp: msg.timestamp,
                                        isError: isError,
                                      ),
                                      if (isError)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 40),
                                          child: TextButton(
                                            onPressed: () => _retryMessage(
                                              chatNotifier,
                                              chatState,
                                              chatState.messages.length -
                                                  1 -
                                                  index,
                                            ),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  const Color(0xFFFCA5A5),
                                              padding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            child: const Text('Retry'),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (_showQuickQuestions && _shouldShowQuickQuestions(chatState))
                  _QuickQuestionsRow(
                    onQuestionTap: (String question) {
                      _textController.text = question;
                      _sendMessage(chatNotifier);
                    },
                    suggestedQuestions: const <String>[
                      'How many steps today?',
                      'Best post-workout meal?',
                      'How to improve sleep?',
                      'Am I active enough?',
                      'Quick 10-min workout?',
                    ],
                  ),
                _InputRow(
                  textController: _textController,
                  isLoading: chatState.isLoading,
                  onSend: () => _sendMessage(chatNotifier),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(ChatController notifier) {
    final String message = _textController.text.trim();
    if (message.isEmpty) {
      FocusScope.of(context).unfocus();
      return;
    }

    setState(() => _showQuickQuestions = false);
    notifier.sendMessage(message);
    _textController.clear();
  }

  void _retryMessage(
    ChatController notifier,
    ChatState chatState,
    int currentChronologicalIndex,
  ) {
    for (int index = currentChronologicalIndex - 1; index >= 0; index--) {
      final ChatMessage previousMessage = chatState.messages[index];
      if (previousMessage.role == ChatRole.user) {
        setState(() => _showQuickQuestions = false);
        notifier.sendMessage(previousMessage.content);
        return;
      }
    }
  }

  void _confirmClearChat(ChatController notifier) async {
    final bool? shouldClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: const Text(
            'Clear chat?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This will reset the conversation to the welcome message.',
            style: TextStyle(color: Color(0xFFCBD5E1)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      notifier.clearMessages();
      setState(() => _showQuickQuestions = true);
    }
  }

  bool _shouldShowQuickQuestions(ChatState chatState) {
    return chatState.messages.length <= 1 && !chatState.isLoading;
  }

  bool _isAiErrorMessage(String message) {
    final String normalized = message.trim().toLowerCase();
    return normalized.startsWith('no internet') ||
        normalized.startsWith('request timed out') ||
        normalized.startsWith('timed out') ||
        normalized.startsWith('something went wrong') ||
        normalized.startsWith('went wrong');
  }
}

class _AppBarStatusDot extends StatefulWidget {
  const _AppBarStatusDot({required this.isLoading});

  final bool isLoading;

  @override
  State<_AppBarStatusDot> createState() => _AppBarStatusDotState();
}

class _AppBarStatusDotState extends State<_AppBarStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color dotColor =
        widget.isLoading ? const Color(0xFFF59E0B) : const Color(0xFF22C55E);

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double pulse =
            widget.isLoading ? 1.0 : 1.0 + (0.18 * _controller.value);
        return Transform.scale(
          scale: pulse,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color:
                      dotColor.withValues(alpha: widget.isLoading ? 0.35 : 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickQuestionsRow extends StatelessWidget {
  const _QuickQuestionsRow({
    required this.onQuestionTap,
    required this.suggestedQuestions,
  });

  final ValueChanged<String> onQuestionTap;
  final List<String> suggestedQuestions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: List<Widget>.generate(
          suggestedQuestions.length,
          (int index) {
            final String question = suggestedQuestions[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                backgroundColor: const Color(0xFF1E293B),
                side: const BorderSide(
                  color: Color(0xFF334155),
                  width: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                label: Text(
                  question,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 13,
                  ),
                ),
                onPressed: () => onQuestionTap(question),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppBarAvatar extends StatelessWidget {
  const _AppBarAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF6366F1), Color(0xFF22D3EE)],
        ),
      ),
      child: const Icon(
        Icons.smart_toy_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class _InputRow extends StatefulWidget {
  const _InputRow({
    required this.textController,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController textController;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  State<_InputRow> createState() => _InputRowState();
}

class _InputRowState extends State<_InputRow> {
  @override
  Widget build(BuildContext context) {
    final bool hasText = widget.textController.text.trim().isNotEmpty;
    final bool canSend = !widget.isLoading && hasText;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF1E293B).withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: widget.textController,
                enabled: !widget.isLoading,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                cursorColor: Colors.white,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Ask SmartWear AI...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: canSend
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[Color(0xFF6366F1), Color(0xFF22D3EE)],
                      )
                    : null,
                color: canSend ? null : const Color(0xFF334155),
                boxShadow: canSend
                    ? <BoxShadow>[
                        BoxShadow(
                          color:
                              const Color(0xFF6366F1).withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : <BoxShadow>[],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: canSend ? widget.onSend : null,
                  child: const Center(
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
