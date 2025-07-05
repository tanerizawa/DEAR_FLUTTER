import 'package:dear_flutter/domain/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

enum ProfileStatus { initial, loading, success, failure }

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(ProfileStatus.initial) ProfileStatus status,
    User? user,
    String? errorMessage,
    Map<String, dynamic>? userStats,
    Map<String, dynamic>? analyticsData,
    String? currentMood,
  }) = _ProfileState;
}
