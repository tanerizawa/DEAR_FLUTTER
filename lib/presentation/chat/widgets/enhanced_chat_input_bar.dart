// lib/presentation/chat/widgets/enhanced_chat_input_bar.dart

import 'dart:async';

import 'package:dear_flutter/presentation/chat/cubit/chat_cubit.dart';
import 'package:dear_flutter/presentation/chat/cubit/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnhancedChatInputBar extends StatefulWidget {
  const EnhancedChatInputBar({super.key});

  @override
  State<EnhancedChatInputBar> createState() => _EnhancedChatInputBarState();
}

class _EnhancedChatInputBarState extends State<EnhancedChatInputBar> 
    with SingleTickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _sendAnimController;
  late Animation<double> _sendScaleAnim;
  Timer? _typingTimer;

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
    _messageController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    if (_messageController.text.trim().isNotEmpty) {
      _sendAnimController.forward();
    } else {
      _sendAnimController.reverse();
    }

    // Typing indicator with debounce
    context.read<ChatCubit>().setTyping(true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      context.read<ChatCubit>().setTyping(false);
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      context.read<ChatCubit>().setTyping(false);
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _messageController.dispose();
    _focusNode.dispose();
    _sendAnimController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _sendMessage(BuildContext context, String message) {
    if (message.trim().isNotEmpty) {
      final cubit = context.read<ChatCubit>();
      final state = cubit.state;
      
      if (state.replyingTo != null) {
        cubit.sendReply(message, state.replyingTo!);
      } else if (state.editingMessage != null) {
        cubit.editMessage(state.editingMessage!.id, message);
      } else {
        cubit.sendMessage(message);
      }
      
      _messageController.clear();
      _focusNode.unfocus();
    }
  }

  void _startVoiceRecording() {
    context.read<ChatCubit>().startVoiceRecording();
  }

  void _stopVoiceRecording() {
    context.read<ChatCubit>().stopVoiceRecording();
  }

  void _cancelVoiceRecording() {
    context.read<ChatCubit>().cancelVoiceRecording();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return Column(
          children: [
            // Reply/Edit Preview
            if (state.replyingTo != null || state.editingMessage != null)
              _buildReplyEditPreview(context, state),
            
            // Main Input Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF232526),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF35363A).withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(8.0),
              child: state.isRecordingVoice
                  ? _buildVoiceRecordingBar(context, state)
                  : _buildTextInputBar(context, state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReplyEditPreview(BuildContext context, ChatState state) {
    final message = state.replyingTo ?? state.editingMessage;
    final isEditing = state.editingMessage != null;
    
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF35363A),
        border: Border(
          top: BorderSide(color: Color(0xFF888888), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: isEditing ? Colors.orange : const Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing ? 'Edit pesan' : 'Balas ${message!.role == 'user' ? 'Anda' : 'Bot'}',
                  style: TextStyle(
                    color: isEditing ? Colors.orange : const Color(0xFF4A90E2),
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message!.content.length > 50 
                      ? '${message.content.substring(0, 50)}...'
                      : message.content,
                  style: const TextStyle(
                    color: Color(0xFFD1D1D1),
                    fontSize: 13,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF888888), size: 20),
            onPressed: () {
              if (isEditing) {
                context.read<ChatCubit>().cancelEdit();
              } else {
                context.read<ChatCubit>().cancelReply();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputBar(BuildContext context, ChatState state) {
    return Row(
      children: [
        // Voice recording button
        IconButton(
          icon: const Icon(Icons.mic, color: Color(0xFF888888)),
          onPressed: _startVoiceRecording,
        ),
        const SizedBox(width: 4),
        
        // Text input field
        Expanded(
          child: TextField(
            controller: _messageController,
            focusNode: _focusNode,
            style: const TextStyle(color: Color(0xFFD1D1D1), fontFamily: 'Montserrat'),
            decoration: InputDecoration(
              hintText: state.replyingTo != null 
                  ? 'Balas pesan...'
                  : state.editingMessage != null
                      ? 'Edit pesan...'
                      : 'Ketik pesan...',
              hintStyle: const TextStyle(color: Color(0xFF888888), fontFamily: 'Montserrat'),
              filled: true,
              fillColor: const Color(0xFF35363A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
            onSubmitted: (value) => _sendMessage(context, value),
            minLines: 1,
            maxLines: 4,
          ),
        ),
        
        const SizedBox(width: 8.0),
        
        // Send button
        ScaleTransition(
          scale: _sendScaleAnim,
          child: IconButton.filled(
            icon: state.isSending
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(
                      strokeWidth: 2, 
                      color: Color(0xFFD1D1D1),
                    ),
                  )
                : Icon(
                    state.editingMessage != null ? Icons.check : Icons.send,
                    color: const Color(0xFFD1D1D1),
                  ),
            onPressed: state.isSending 
                ? null 
                : () => _sendMessage(context, _messageController.text),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: const Color(0xFFD1D1D1),
              shape: const CircleBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceRecordingBar(BuildContext context, ChatState state) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF35363A),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          
          // Recording indicator
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Recording text and timer
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Merekam audio...',
                  style: TextStyle(
                    color: Color(0xFFD1D1D1),
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  state.voiceRecordingDuration != null
                      ? _formatDuration(state.voiceRecordingDuration!)
                      : '00:00',
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Cancel button
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF888888)),
            onPressed: _cancelVoiceRecording,
          ),
          
          // Stop/Send button
          IconButton.filled(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _stopVoiceRecording,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              shape: const CircleBorder(),
            ),
          ),
          
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
