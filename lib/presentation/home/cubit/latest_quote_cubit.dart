import 'package:dear_flutter/domain/repositories/quote_cache_repository.dart';
import 'package:dear_flutter/domain/usecases/get_latest_quote_usecase.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class LatestQuoteCubit extends Cubit<LatestQuoteState> {
  final GetLatestQuoteUseCase _getLatestQuoteUseCase;
  final QuoteCacheRepository _cacheRepository;

  LatestQuoteCubit(
    this._getLatestQuoteUseCase,
    this._cacheRepository,
  ) : super(const LatestQuoteState()) {
    fetchLatestQuote();
  }

  Future<void> fetchLatestQuote() async {
    final cached = _cacheRepository.getLastQuote();
    final hasCache = cached != null;
    if (hasCache) {
      emit(state.copyWith(status: LatestQuoteStatus.cached, quote: cached));
    } else {
      emit(state.copyWith(status: LatestQuoteStatus.loading));
    }
    try {
      final quote = await _getLatestQuoteUseCase();
      emit(state.copyWith(status: LatestQuoteStatus.success, quote: quote));
      await _cacheRepository.saveQuote(quote);
    } catch (_) {
      if (!hasCache) {
        emit(state.copyWith(
          status: LatestQuoteStatus.failure,
          errorMessage: 'Gagal memuat quote.',
        ));
      }
    }
  }
}
