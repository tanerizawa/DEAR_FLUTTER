import 'package:dear_flutter/domain/entities/chat_message.dart';
import 'package:dear_flutter/domain/repositories/chat_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetChatHistoryUseCase {
  final ChatRepository _repository;

  GetChatHistoryUseCase(this._repository);

  Stream<List<ChatMessage>> call() {
    return _repository.getChatHistory();
  }
}
