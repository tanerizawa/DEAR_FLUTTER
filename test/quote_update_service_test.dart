import 'package:dear_flutter/data/datasources/remote/home_api_service.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/repositories/quote_cache_repository.dart';
import 'package:dear_flutter/services/notification_service.dart';
import 'package:dear_flutter/services/quote_update_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiService extends Mock implements HomeApiService {}
class _MockCacheRepo extends Mock implements QuoteCacheRepository {}
class _MockNotificationService extends Mock implements NotificationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fetch falls back to cached quote on error', () async {
    final api = _MockApiService();
    final cache = _MockCacheRepo();
    final notif = _MockNotificationService();
    const cached = MotivationalQuote(id: 1, text: 'q', author: 'a');

    when(() => api.getLatestQuote()).thenThrow(Exception());
    when(() => cache.getLastQuote()).thenReturn(cached);

    final service = QuoteUpdateService(api, notif, cache);
    final result = await service.refresh();

    expect(result, cached);
  });
}
