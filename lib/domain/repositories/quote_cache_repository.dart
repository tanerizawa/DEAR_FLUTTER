import 'package:dear_flutter/domain/entities/motivational_quote.dart';

abstract class QuoteCacheRepository {
  Future<void> saveQuote(MotivationalQuote quote);
  MotivationalQuote? getLastQuote();
}
