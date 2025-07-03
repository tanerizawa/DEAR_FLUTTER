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

    final cubit = LatestQuoteCubit(service);

    expect(cubit.state.status, LatestQuoteStatus.cached);
    expect(cubit.state.quote, quote);
  });
}
