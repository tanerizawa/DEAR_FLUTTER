import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/entities/chat_message.dart';
import 'package:dear_flutter/presentation/chat/cubit/chat_cubit.dart';
import 'package:dear_flutter/presentation/chat/cubit/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final atBottom = _scrollController.offset >= _scrollController.position.maxScrollExtent - 40;
    if (_showScrollToBottom == atBottom) {
      setState(() {
        _showScrollToBottom = !atBottom;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatCubit>(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: const Color(0xFF232526),
          elevation: 0,
          title: const Text('Ruang Cerita', style: TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF232526), // Monochrome dark background
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: BlocConsumer<ChatCubit, ChatState>(
                      listener: (context, state) {
                        // Scroll ke bawah setiap kali ada pesan baru
                        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                        if (state.status == ChatStatus.failure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Gagal mengirim pesan'),
                              action: SnackBarAction(
                                label: 'Coba Lagi',
                                onPressed: () {
                                  if (state.lastFailedMessage != null) {
                                    context.read<ChatCubit>().sendMessage(state.lastFailedMessage!);
                                  }
                                },
                              ),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state.status == ChatStatus.loading && state.messages.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state.messages.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 56, color: Color(0xFF888888)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Mulai percakapan...\nTanyakan apa saja!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFFD1D1D1), fontSize: 16, fontFamily: 'Montserrat'),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8.0),
                          itemCount: state.messages.length + (state.isSending ? 1 : 0),
                          itemBuilder: (context, index) {
                            final key = ValueKey(index < state.messages.length ? state.messages[index].id : 'loading');
                            final isLast = index == state.messages.length - 1;
                            final isFirst = index == 0;
                            final isLoadingBubble = index >= state.messages.length;
                            String? prevRole;
                            String? nextRole;
                            DateTime? prevDate;
                            if (!isLoadingBubble) {
                              if (!isFirst) prevRole = state.messages[index - 1].role;
                              if (!isLast) nextRole = state.messages[index + 1].role;
                              if (!isFirst) prevDate = state.messages[index - 1].timestamp;
                            }
                            Widget? dateSeparator;
                            if (!isLoadingBubble && (isFirst || !_isSameDay(state.messages[index].timestamp, prevDate))) {
                              dateSeparator = Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF35363A),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _formatDate(state.messages[index].timestamp),
                                      style: const TextStyle(
                                        color: Color(0xFFD1D1D1),
                                        fontSize: 12,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (!isLoadingBubble) {
                              final message = state.messages[index];
                              final showAvatar = isLast || message.role != (nextRole ?? '');
                              final showTimestamp = isLast || message.role != (nextRole ?? '');
                              final isGroupTop = isFirst || message.role != (prevRole ?? '');
                              final isGroupBottom = isLast || message.role != (nextRole ?? '');
                              final bubble = AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                transitionBuilder: (child, anim) => SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.1, 0),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: FadeTransition(opacity: anim, child: child),
                                ),
                                child: _ChatMessageBubble(
                                  key: key,
                                  message: message,
                                  showAvatar: showAvatar,
                                  showTimestamp: showTimestamp,
                                  isGroupTop: isGroupTop,
                                  isGroupBottom: isGroupBottom,
                                ),
                              );
                              if (dateSeparator != null) {
                                return Column(
                                  children: [dateSeparator, bubble],
                                );
                              } else {
                                return bubble;
                              }
                            } else {
                              // Loading bubble at the end
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                transitionBuilder: (child, anim) => SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.1, 0),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: FadeTransition(opacity: anim, child: child),
                                ),
                                child: _ChatMessageBubble(
                                  key: key,
                                  message: ChatMessage(
                                    id: 'loading',
                                    role: 'bot',
                                    content: '',
                                    timestamp: DateTime.now(),
                                  ),
                                  isLoading: true,
                                  showAvatar: true,
                                  showTimestamp: false,
                                  isGroupTop: true,
                                  isGroupBottom: true,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  _ChatInputBar(controller: _messageController),
                ],
              ),
              if (_showScrollToBottom)
                Positioned(
                  bottom: 80,
                  right: 20,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFF35363A),
                    foregroundColor: const Color(0xFFD1D1D1),
                    onPressed: _scrollToBottom,
                    child: const Icon(Icons.arrow_downward),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget untuk gelembung chat
class _ChatMessageBubble extends StatefulWidget {
  const _ChatMessageBubble({
    Key? key,
    required this.message,
    this.isLoading = false,
    this.showAvatar = true,
    this.showTimestamp = true,
    this.isGroupTop = true,
    this.isGroupBottom = true,
  }) : super(key: key);

  final ChatMessage message;
  final bool isLoading;
  final bool showAvatar;
  final bool showTimestamp;
  final bool isGroupTop;
  final bool isGroupBottom;

  @override
  State<_ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<_ChatMessageBubble> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<int>? _dotCount;

  @override
  void initState() {
    super.initState();
    if (widget.isLoading) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat();
      _dotCount = StepTween(begin: 1, end: 3).animate(CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == 'user';
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser
        ? const Color(0xFF4A90E2)
        : const Color(0xFF35363A);
    final textColor = isUser ? Colors.white : const Color(0xFFEFEFEF);

    return Container(
      margin: EdgeInsets.only(
        top: widget.isGroupTop ? 10 : 2,
        bottom: widget.isGroupBottom ? 10 : 2,
        left: isUser ? 40 : 8,
        right: isUser ? 8 : 40,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && widget.showAvatar)
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 2.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF35363A),
                child: Icon(Icons.android, color: Color(0xFFD1D1D1), size: 18), // Bot avatar
              ),
            ),
          GestureDetector(
            onLongPress: widget.isLoading ? null : () {
              if (!widget.isLoading) {
                Clipboard.setData(ClipboardData(text: widget.message.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pesan disalin'), duration: Duration(milliseconds: 900)),
                );
              }
            },
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.68),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isUser ? (widget.isGroupTop ? 18 : 6) : 6),
                      topRight: Radius.circular(isUser ? 6 : (widget.isGroupTop ? 18 : 6)),
                      bottomLeft: Radius.circular(widget.isGroupBottom ? 18 : 6),
                      bottomRight: Radius.circular(widget.isGroupBottom ? 18 : 6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.13),
                        blurRadius: 12,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: isUser ? 22.0 : 0),
                        child: widget.isLoading
                            ? AnimatedBuilder(
                                animation: _controller!,
                                builder: (context, child) {
                                  final dots = '.' * (_dotCount?.value ?? 1);
                                  return Text(
                                    'Mengetik$dots',
                                    style: TextStyle(
                                      color: textColor,
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                    ),
                                  );
                                },
                              )
                            : Text(
                                widget.message.content,
                                style: TextStyle(
                                  color: textColor,
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1.35,
                                ),
                              ),
                      ),
                      if (isUser && !widget.isLoading)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(Icons.check, size: 16, color: Color(0xFFD1D1D1)),
                        ),
                    ],
                  ),
                ),
                if (!widget.isLoading && widget.showTimestamp)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0, left: 6.0, right: 6.0),
                    child: Text(
                      _formatTime(widget.message.timestamp),
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 11,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isUser && widget.showAvatar)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF4A90E2),
                child: Icon(Icons.person, color: Colors.white, size: 18), // User avatar
              ),
            ),
        ],
      ),
    );
  }
}

// Widget untuk input bar (versi yang sudah diperbaiki)
class _ChatInputBar extends StatefulWidget {
  const _ChatInputBar({required this.controller});

  final TextEditingController controller;

  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> with SingleTickerProviderStateMixin {
  late AnimationController _sendAnimController;
  late Animation<double> _sendScaleAnim;

  @override
  void initState() {
    super.initState();
    _sendAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 1.0,
      upperBound: 1.18,
    );
    _sendScaleAnim = _sendAnimController.drive(Tween(begin: 1.0, end: 1.18));
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (widget.controller.text.trim().isNotEmpty) {
      _sendAnimController.forward();
    } else {
      _sendAnimController.reverse();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _sendAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              style: const TextStyle(color: Color(0xFFD1D1D1), fontFamily: 'Montserrat'),
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                hintStyle: const TextStyle(color: Color(0xFF888888), fontFamily: 'Montserrat'),
                filled: true,
                fillColor: Color(0xFF232526), // Monochrome dark background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: const BorderSide(color: Color(0xFF35363A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: const BorderSide(color: Color(0xFF35363A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onSubmitted: (value) {
                _sendMessage(context, value);
              },
            ),
          ),
          const SizedBox(width: 8.0),
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              return ScaleTransition(
                scale: _sendScaleAnim,
                child: IconButton.filled(
                  icon: state.isSending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD1D1D1)))
                      : const Icon(Icons.send, color: Color(0xFFD1D1D1)),
                  onPressed: state.isSending ? null : () => _sendMessage(context, widget.controller.text),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF35363A),
                    foregroundColor: const Color(0xFFD1D1D1),
                    shape: const CircleBorder(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context, String message) {
    if (message.trim().isNotEmpty) {
      context.read<ChatCubit>().sendMessage(message);
      widget.controller.clear();
      FocusScope.of(context).unfocus(); // Menutup keyboard setelah mengirim
    }
  }
}

bool _isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final d = DateTime(date.year, date.month, date.day);
  if (d == today) return 'Hari ini';
  if (d == yesterday) return 'Kemarin';
  return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
}

String _formatTime(DateTime time) {
  return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
}
