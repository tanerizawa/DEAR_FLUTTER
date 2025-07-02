import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'latest_quote_state.freezed.dart';

enum LatestQuoteStatus { initial, loading, cached, success, failure }

@freezed
class LatestQuoteState with _$LatestQuoteState {
  const factory LatestQuoteState({
    @Default(LatestQuoteStatus.initial) LatestQuoteStatus status,
    MotivationalQuote? quote,
    String? errorMessage,
  }) = _LatestQuoteState;
}
