import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dear_flutter/domain/entities/home_feed_item.dart';

part 'home_feed_state.freezed.dart';

enum HomeFeedStatus { initial, loading, success, failure }

@freezed
class HomeFeedState with _$HomeFeedState {
  const factory HomeFeedState({
    @Default(HomeFeedStatus.initial) HomeFeedStatus status,
    @Default([]) List<HomeFeedItem> items,
    String? errorMessage,
  }) = _HomeFeedState;
}
