import 'package:freezed_annotation/freezed_annotation.dart';

part 'motivational_quote.freezed.dart';
part 'motivational_quote.g.dart';

@freezed
class MotivationalQuote with _$MotivationalQuote {
  const factory MotivationalQuote({
    required int id,
    required String text,
    required String author,
  }) = _MotivationalQuote;

  factory MotivationalQuote.fromJson(Map<String, dynamic> json) =>
      _$MotivationalQuoteFromJson(json);
}
