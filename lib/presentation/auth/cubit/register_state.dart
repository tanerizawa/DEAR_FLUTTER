import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_state.freezed.dart';

// Kita bisa gunakan enum yang sama dengan Login
enum AuthStatus { initial, loading, success, failure }

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default(AuthStatus.initial) AuthStatus status,
    String? errorMessage,
  }) = _RegisterState;
}
