import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/repositories/quote_cache_repository.dart';

@LazySingleton(as: QuoteCacheRepository)
class QuoteCacheRepositoryImpl implements QuoteCacheRepository {
  final Box<Map> _box;

  QuoteCacheRepositoryImpl(@Named('quoteBox') this._box);

  @override
  Future<void> saveQuote(MotivationalQuote quote) =>
      _box.put('latest', quote.toJson());

  @override
  MotivationalQuote? getLastQuote() {
    final data = _box.get('latest');
    if (data == null) return null;
    return MotivationalQuote.fromJson(Map<String, dynamic>.from(data));
  }
}
