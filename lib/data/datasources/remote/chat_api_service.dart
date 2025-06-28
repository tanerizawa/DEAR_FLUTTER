import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'chat_api_service.freezed.dart';
part 'chat_api_service.g.dart';

// Model untuk request dan response
@freezed
class ChatRequest with _$ChatRequest {
  const factory ChatRequest({required String message}) = _ChatRequest;
  factory ChatRequest.fromJson(Map<String, dynamic> json) => _$ChatRequestFromJson(json);
}

@freezed
class ChatResponse with _$ChatResponse {
  const factory ChatResponse({
    @JsonKey(name: 'content') required String reply,
    String? emotion,
  }) = _ChatResponse;
  factory ChatResponse.fromJson(Map<String, dynamic> json) => _$ChatResponseFromJson(json);
}

@lazySingleton
class ChatApiService {
  final Dio _dio;
  ChatApiService(this._dio);

  // POST /chat/
  Future<ChatResponse> postMessage(ChatRequest request) async {
    final response = await _dio.post('chat/', data: request.toJson());
    return ChatResponse.fromJson(response.data);
  }
}
