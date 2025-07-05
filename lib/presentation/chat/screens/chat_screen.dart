import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/entities/chat_message.dart';
import 'package:dear_flutter/presentation/chat/cubit/chat_cubit.dart';
import 'package:dear_flutter/presentation/chat/cubit/chat_state.dart';
import 'package:dear_flutter/presentation/chat/widgets/enhanced_chat_message_bubble.dart';
import 'package:dear_flutter/presentation/chat/widgets/enhanced_chat_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if (state.isSearching) {
                return AppBar(
                  backgroundColor: const Color(0xFF232526),
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.read<ChatCubit>().exitSearch(),
                  ),
                  title: TextField(
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                    decoration: const InputDecoration(
                      hintText: 'Cari pesan...',
                      hintStyle: TextStyle(color: Color(0xFF888888), fontFamily: 'Montserrat'),
                      border: InputBorder.none,
                    ),
                    onChanged: (query) => context.read<ChatCubit>().searchMessages(query),
                  ),
                  actions: [
                    if (state.searchQuery?.isNotEmpty == true)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () => context.read<ChatCubit>().clearSearch(),
                      ),
                  ],
                );
              }
              return AppBar(
                backgroundColor: const Color(0xFF232526),
                elevation: 0,
                title: const Text('Ruang Cerita', style: TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () => context.read<ChatCubit>().enterSearch(),
                  ),
                ],
              );
            },
          ),
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
                                child: EnhancedChatMessageBubble(
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
                                child: EnhancedChatMessageBubble(
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
                  EnhancedChatInputBar(),
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
