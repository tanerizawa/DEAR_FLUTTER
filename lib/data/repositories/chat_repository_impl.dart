import 'package:dear_flutter/data/datasources/local/app_database.dart';
import 'package:dear_flutter/data/datasources/local/chat_message_dao.dart';
import 'package:dear_flutter/data/datasources/remote/chat_api_service.dart';
import 'package:dear_flutter/domain/entities/chat_message.dart';
import 'package:dear_flutter/domain/repositories/chat_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatApiService _apiService;
  final ChatMessageDao _dao;
  final Uuid _uuid; // Untuk membuat ID unik

  ChatRepositoryImpl(this._apiService, this._dao) : _uuid = const Uuid();

  @override
  Stream<List<ChatMessage>> getChatHistory() {
    // Ambil data dari DAO, lalu ubah dari format database ke format domain
    return _dao.watchAllMessages().map((entities) => entities.map(_mapToDomain).toList());
  }

  @override
  Future<void> sendMessage(String message) async {
    // 1. Buat dan simpan pesan pengguna ke DB lokal
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      role: 'user',
      content: message,
      timestamp: DateTime.now(),
    );
    await _dao.insertMessage(_mapToEntity(userMessage));

    try {
      // 2. Kirim ke API dan tunggu balasan
      final response = await _apiService.postMessage(ChatRequest(message: message));

      // 3. Buat dan simpan balasan AI ke DB lokal
      final assistantMessage = ChatMessage(
        id: _uuid.v4(),
        role: 'assistant',
        content: response.reply,
        emotion: response.emotion,
        timestamp: DateTime.now(),
      );
      await _dao.insertMessage(_mapToEntity(assistantMessage));
    } catch (e) {
      // Jika gagal, buat pesan error dan simpan ke DB
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        role: 'assistant',
        content: 'Maaf, terjadi kesalahan. Coba lagi nanti.',
        timestamp: DateTime.now(),
      );
      await _dao.insertMessage(_mapToEntity(errorMessage));
      rethrow; // Lempar kembali error agar bisa ditangani di lapisan atas
    }
  }

  // --- Mappers ---
  ChatMessage _mapToDomain(ChatMessageEntity entity) {
    return ChatMessage(
      id: entity.id,
      role: entity.role,
      content: entity.content,
      emotion: entity.emotion,
      timestamp: entity.timestamp,
    );
  }

  ChatMessageEntity _mapToEntity(ChatMessage message) {
    return ChatMessageEntity(
      id: message.id,
      role: message.role,
      content: message.content,
      emotion: message.emotion,
      timestamp: message.timestamp,
    );
  }
}
