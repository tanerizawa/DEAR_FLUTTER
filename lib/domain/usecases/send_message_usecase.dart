import 'package:dear_flutter/domain/repositories/chat_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<void> call(String message) {
    if (message.trim().isEmpty) {
      // Jangan kirim pesan kosong
      return Future.value();
    }
    return _repository.sendMessage(message);
  }
}
