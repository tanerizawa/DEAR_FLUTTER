import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/services/quote_update_service.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockQuoteUpdateService extends Mock implements QuoteUpdateService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads cached quote on init', () async {
    const quote = MotivationalQuote(id: 1, text: 't', author: 'a');
    final service = _MockQuoteUpdateService();
    when(() => service.latest).thenReturn(quote);
    when(() => service.hasFetchedInitial).thenReturn(false);

    final cubit = LatestQuoteCubit(service);

    expect(cubit.state.status, LatestQuoteStatus.cached);
    expect(cubit.state.quote, quote);
  });

  test('fetchLatestQuote retrieves quote from service', () async {
    const quote = MotivationalQuote(id: 1, text: 't', author: 'a');
    final service = _MockQuoteUpdateService();
    when(() => service.latest).thenReturn(null);
    when(service.refresh).thenAnswer((_) async => quote);
    when(() => service.hasFetchedInitial).thenReturn(false);

    final cubit = LatestQuoteCubit(service);
    await cubit.fetchLatestQuote();

    expect(cubit.state.status, LatestQuoteStatus.success);
    expect(cubit.state.quote, quote);
    verify(service.refresh).called(1);
  });

  test('does not refresh when service already fetched initial data', () async {
    const quote = MotivationalQuote(id: 1, text: 't', author: 'a');
    final service = _MockQuoteUpdateService();
    when(() => service.latest).thenReturn(quote);
    when(() => service.hasFetchedInitial).thenReturn(true);

    final cubit = LatestQuoteCubit(service);
    await cubit.fetchLatestQuote();

    expect(cubit.state.status, LatestQuoteStatus.success);
    expect(cubit.state.quote, quote);
    verifyNever(() => service.refresh());
  });
}
