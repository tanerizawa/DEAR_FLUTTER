import 'package:dear_flutter/core/di/injection.dart';
import 'package:dear_flutter/domain/entities/chat_message.dart';
import 'package:dear_flutter/presentation/chat/cubit/chat_cubit.dart';
import 'package:dear_flutter/presentation/chat/cubit/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
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
        appBar: AppBar(
          title: const Text('Chat dengan Dear'),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  // Scroll ke bawah setiap kali ada pesan baru
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                },
                builder: (context, state) {
                  if (state.status == ChatStatus.loading && state.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.messages.isEmpty) {
                    return const Center(child: Text('Mulai percakapan...'));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return _ChatMessageBubble(message: message);
                    },
                  );
                },
              ),
            ),
            _ChatInputBar(controller: _messageController),
          ],
        ),
      ),
    );
  }
}

// Widget untuk gelembung chat
class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant;
    final textColor = isUser ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              message.content,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk input bar (versi yang sudah diperbaiki)
class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
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
              return IconButton.filled(
                icon: state.isSending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                onPressed: state.isSending ? null : () => _sendMessage(context, controller.text),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  // VVVV PERBAIKAN DI SINI VVVV
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
      controller.clear();
      FocusScope.of(context).unfocus(); // Menutup keyboard setelah mengirim
    }
  }
}
