// lib/presentation/chat/widgets/enhanced_chat_message_bubble.dart

import 'dart:async';

import 'package:dear_flutter/domain/entities/chat_message.dart';
import 'package:dear_flutter/presentation/chat/cubit/chat_cubit.dart';
import 'package:dear_flutter/core/theme/mood_color_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnhancedChatMessageBubble extends StatefulWidget {
  const EnhancedChatMessageBubble({
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
  State<EnhancedChatMessageBubble> createState() => _EnhancedChatMessageBubbleState();
}

class _EnhancedChatMessageBubbleState extends State<EnhancedChatMessageBubble> 
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<int>? _dotCount;
  bool _showReactions = false;

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
                child: Icon(Icons.android, color: Color(0xFFD1D1D1), size: 18),
              ),
            ),
          Flexible(
            child: GestureDetector(
              onLongPress: widget.isLoading ? null : () => _showMessageOptions(context),
              onDoubleTap: widget.isLoading ? null : () => _showQuickReactions(),
              child: Column(
                crossAxisAlignment: alignment,
                children: [
                  // Reply indicator if this is a reply
                  if (widget.message.replyToId != null)
                    _buildReplyIndicator(context),
                  
                  // Main message bubble
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.68),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: widget.message.isDeleted ? Theme.of(context).colorScheme.surfaceContainer : color,
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
                          child: _buildMessageContent(textColor),
                        ),
                        if (isUser && !widget.isLoading)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: _buildMessageStatus(),
                          ),
                      ],
                    ),
                  ),
                  
                  // Reactions
                  if (widget.message.reactions.isNotEmpty)
                    _buildReactions(context),
                  
                  // Timestamp and edit indicator
                  if (!widget.isLoading && widget.showTimestamp)
                    _buildTimestamp(),
                ],
              ),
            ),
          ),
          if (isUser && widget.showAvatar)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF4A90E2),
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Color textColor) {
    if (widget.isLoading) {
      return AnimatedBuilder(
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
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.message.content,
          style: TextStyle(
            color: textColor,
            fontFamily: 'Montserrat',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.35,
            fontStyle: widget.message.isDeleted ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        if (widget.message.isEdited && !widget.message.isDeleted)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'diedit',
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageStatus() {
    switch (widget.message.status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
          ),
        );
      case MessageStatus.sent:
        return Icon(Icons.check, size: 16, color: Color(0xFFD1D1D1));
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 16, color: Color(0xFFD1D1D1));
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 16, color: Colors.blue);
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 16, color: Colors.red);
    }
  }

  Widget _buildReplyIndicator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.reply, size: 16, color: MoodColorSystem.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            'Reply to message',
            style: TextStyle(
              color: MoodColorSystem.onSurfaceVariant,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: widget.message.reactions.map((reaction) {
          return GestureDetector(
            onTap: () => context.read<ChatCubit>().removeReaction(widget.message.id, reaction),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: MoodColorSystem.surfaceContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                reaction,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, left: 6.0, right: 6.0),
      child: Text(
        _formatTime(widget.message.timestamp),
        style: const TextStyle(
          color: Color(0xFFB8B8B8), // High contrast secondary text
          fontSize: 11,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    final isUser = widget.message.role == 'user';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF35363A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: MoodColorSystem.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.white),
              title: const Text('Copy', style: TextStyle(color: Colors.white)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.message.content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.reply, color: Colors.white),
              title: const Text('Reply', style: TextStyle(color: Colors.white)),
              onTap: () {
                context.read<ChatCubit>().setReplyTo(widget.message.id);
                Navigator.pop(context);
              },
            ),
            if (isUser && !widget.message.isDeleted) ...[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text('Edit', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.read<ChatCubit>().setEditingMessage(widget.message);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  context.read<ChatCubit>().deleteMessage(widget.message.id);
                  Navigator.pop(context);
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showQuickReactions() {
    setState(() {
      _showReactions = !_showReactions;
    });

    if (_showReactions) {
      // Auto-hide after 3 seconds
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showReactions = false;
          });
        }
      });
    }
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
