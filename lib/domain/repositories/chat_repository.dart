import 'package:dear_flutter/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> getChatHistory();
  Future<void> sendMessage(String message);
}
