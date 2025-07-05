import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum MessageStatus { sending, sent, delivered, read, failed }
enum MessageType { text, image, audio, file, voice }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String role,
    required String content,
    String? emotion,
    required DateTime timestamp,
    @Default(MessageStatus.sent) MessageStatus status,
    @Default(MessageType.text) MessageType type,
    String? mediaUrl,
    String? mediaType,
    @Default(false) bool isEdited,
    DateTime? editedAt,
    @Default([]) List<String> reactions,
    String? replyToId,
    @Default(false) bool isDeleted,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}
