// lib/data/models/requests.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'requests.freezed.dart';
part 'requests.g.dart';

// --- Auth Requests ---
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String username,
    required String email,
    required String password,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

// --- Journal Requests ---
@freezed
class CreateJournalRequest with _$CreateJournalRequest {
  const factory CreateJournalRequest({
    required String title,
    required String content,
    required String mood,
  }) = _CreateJournalRequest;

  factory CreateJournalRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateJournalRequestFromJson(json);
}

// Tambahkan request lain di sini jika ada...
