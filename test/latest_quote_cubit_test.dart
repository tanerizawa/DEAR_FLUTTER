import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/repositories/quote_cache_repository.dart';
import 'package:dear_flutter/domain/usecases/get_latest_quote_usecase.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetLatestQuoteUseCase extends Mock implements GetLatestQuoteUseCase {}

class _FakeCacheRepo implements QuoteCacheRepository {
  MotivationalQuote? quote;

  @override
  Future<void> saveQuote(MotivationalQuote quote) async {
    this.quote = quote;
  }

  @override
  MotivationalQuote? getLastQuote() => quote;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('emits cached quote when api fails', () async {
    final usecase = _MockGetLatestQuoteUseCase();
    final cache = _FakeCacheRepo()
      ..quote = const MotivationalQuote(id: 1, text: 't', author: 'a');
    when(() => usecase()).thenThrow(Exception());

    final cubit = LatestQuoteCubit(usecase, cache);
    final states = <LatestQuoteState>[];
    final sub = cubit.stream.listen(states.add);

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(states, hasLength(1));
    expect(states.first.status, LatestQuoteStatus.cached);
    expect(states.first.quote, cache.quote);
    await sub.cancel();
  });
}
