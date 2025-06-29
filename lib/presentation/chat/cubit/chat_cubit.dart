// lib/presentation/chat/cubit/chat_cubit.dart

import 'dart:async';

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
    } catch (e) {
      // Error sudah ditangani di repository, di sini kita hanya menghentikan loading
    }
    emit(state.copyWith(isSending: false));
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    return super.close();
  }
}