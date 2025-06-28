// lib/presentation/home/cubit/home_state.dart

import 'package:dear_flutter/domain/entities/journal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

enum HomeStatus { initial, loading, success, failure }

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(HomeStatus.initial) HomeStatus status,
    @Default([]) List<Journal> journals,
    String? errorMessage,
  }) = _HomeState;
}
