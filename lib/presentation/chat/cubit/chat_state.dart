// lib/presentation/chat/cubit/chat_state.dart

import 'package:dear_flutter/domain/entities/chat_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_state.freezed.dart';

enum ChatStatus { initial, loading, success, failure }

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default(ChatStatus.initial) ChatStatus status,
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isSending,
    @Default(false) bool isTyping,
    @Default(false) bool hasMoreMessages,
    @Default(false) bool isLoadingMore,
    @Default(false) bool isSearching,
    String? errorMessage,
    String? lastFailedMessage,
    String? searchQuery,
    @Default([]) List<ChatMessage> searchResults,
    ChatMessage? editingMessage,
    ChatMessage? replyingTo,
    @Default(false) bool isRecordingVoice,
    Duration? voiceRecordingDuration,
  }) = _ChatState;
}
