// lib/presentation/chat/cubit/chat_cubit.dart

import 'dart:async';

import 'package:dear_flutter/domain/entities/chat_message.dart';
import 'package:dear_flutter/domain/usecases/get_chat_history_usecase.dart';
import 'package:dear_flutter/domain/usecases/send_message_usecase.dart';
import 'package:dear_flutter/presentation/chat/cubit/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChatCubit extends Cubit<ChatState> {
  final GetChatHistoryUseCase _getChatHistoryUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  StreamSubscription? _chatSubscription;
  Timer? _typingTimer;

  ChatCubit(this._getChatHistoryUseCase, this._sendMessageUseCase)
      : super(const ChatState()) {
    watchChatHistory();
  }

  void watchChatHistory() {
    emit(state.copyWith(status: ChatStatus.loading));
    _chatSubscription?.cancel();
    _chatSubscription = _getChatHistoryUseCase().listen((messages) {
      emit(state.copyWith(status: ChatStatus.success, messages: messages));
    });
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    emit(state.copyWith(isSending: true));
    try {
      await _sendMessageUseCase(message);
      emit(state.copyWith(isSending: false, lastFailedMessage: null, status: ChatStatus.success));
    } catch (e) {
      emit(state.copyWith(
        isSending: false,
        status: ChatStatus.failure,
        lastFailedMessage: message,
        errorMessage: e.toString(),
      ));
    }
  }

  // Enhanced typing indicator
  void setTyping(bool isTyping) {
    _typingTimer?.cancel();
    emit(state.copyWith(isTyping: isTyping));
    
    if (isTyping) {
      // Auto-stop typing after 3 seconds
      _typingTimer = Timer(const Duration(seconds: 3), () {
        emit(state.copyWith(isTyping: false));
      });
    }
  }

  // Message reactions
  Future<void> addReaction(String messageId, String reaction) async {
    final messages = state.messages.map((msg) {
      if (msg.id == messageId) {
        final reactions = List<String>.from(msg.reactions);
        if (!reactions.contains(reaction)) {
          reactions.add(reaction);
        }
        return msg.copyWith(reactions: reactions);
      }
      return msg;
    }).toList();
    
    emit(state.copyWith(messages: messages));
  }

  Future<void> removeReaction(String messageId, String reaction) async {
    final messages = state.messages.map((msg) {
      if (msg.id == messageId) {
        final reactions = List<String>.from(msg.reactions);
        reactions.remove(reaction);
        return msg.copyWith(reactions: reactions);
      }
      return msg;
    }).toList();
    
    emit(state.copyWith(messages: messages));
  }

  // Message editing
  void setEditingMessage(ChatMessage message) {
    emit(state.copyWith(editingMessage: message));
  }

  void cancelEdit() {
    emit(state.copyWith(editingMessage: null));
  }

  Future<void> editMessage(String messageId, String newContent) async {
    if (newContent.trim().isEmpty) return;
    
    final messages = state.messages.map((msg) {
      if (msg.id == messageId && msg.role == 'user') {
        return msg.copyWith(
          content: newContent,
          isEdited: true,
          editedAt: DateTime.now(),
        );
      }
      return msg;
    }).toList();
    
    emit(state.copyWith(
      messages: messages,
      editingMessage: null,
    ));
  }

  // Reply functionality
  void sendReply(String message, ChatMessage replyingTo) {
    // TODO: Implement reply with backend
    sendMessage(message);
    cancelReply();
  }

  void setReplyingTo(ChatMessage message) {
    emit(state.copyWith(replyingTo: message));
  }

  void cancelReply() {
    emit(state.copyWith(replyingTo: null));
  }

  // Message deletion
  Future<void> deleteMessage(String messageId) async {
    final messages = state.messages.map((msg) {
      if (msg.id == messageId && msg.role == 'user') {
        return msg.copyWith(
          isDeleted: true,
          content: 'Pesan telah dihapus',
        );
      }
      return msg;
    }).toList();
    
    emit(state.copyWith(messages: messages));
  }

  // Search functionality
  void enterSearch() {
    emit(state.copyWith(isSearching: true));
  }

  void exitSearch() {
    emit(state.copyWith(
      isSearching: false,
      searchQuery: null,
      searchResults: [],
    ));
  }

  void clearSearch() {
    emit(state.copyWith(
      searchQuery: null,
      searchResults: [],
    ));
  }

  void searchMessages(String query) {
    if (query.trim().isEmpty) {
      emit(state.copyWith(
        searchQuery: null,
        searchResults: [],
        isSearching: false,
      ));
      return;
    }

    emit(state.copyWith(isSearching: true, searchQuery: query));
    
    final results = state.messages.where((message) {
      return message.content.toLowerCase().contains(query.toLowerCase()) &&
             !message.isDeleted;
    }).toList();
    
    emit(state.copyWith(
      searchResults: results,
      isSearching: false,
    ));
  }

  // Reply to message (legacy method for ID-based approach)
  void setReplyTo(String? messageId) {
    final message = messageId != null 
        ? state.messages.firstWhere((msg) => msg.id == messageId)
        : null;
    emit(state.copyWith(replyingTo: message));
  }

  // Voice recording
  void startVoiceRecording() {
    emit(state.copyWith(isRecordingVoice: true, voiceRecordingDuration: Duration.zero));
    // TODO: Start actual voice recording
  }

  void stopVoiceRecording() {
    // TODO: Stop recording and send voice message
    emit(state.copyWith(isRecordingVoice: false, voiceRecordingDuration: null));
  }

  void cancelVoiceRecording() {
    emit(state.copyWith(isRecordingVoice: false, voiceRecordingDuration: null));
  }

  void updateVoiceRecordingDuration(Duration duration) {
    emit(state.copyWith(voiceRecordingDuration: duration));
  }

  // Load more messages (pagination)
  Future<void> loadMoreMessages() async {
    if (state.isLoadingMore || !state.hasMoreMessages) return;
    
    emit(state.copyWith(isLoadingMore: true));
    
    // TODO: Implement pagination logic with repository
    // For now, just simulate loading
    await Future.delayed(const Duration(seconds: 1));
    
    emit(state.copyWith(isLoadingMore: false));
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    _typingTimer?.cancel();
    return super.close();
  }
}
