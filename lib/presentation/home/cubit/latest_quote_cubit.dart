import 'package:dear_flutter/services/quote_update_service.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class LatestQuoteCubit extends Cubit<LatestQuoteState> {
  final QuoteUpdateService _updateService;

  LatestQuoteCubit(this._updateService) : super(const LatestQuoteState()) {
    final cached = _updateService.latest;
    if (cached != null) {
      emit(state.copyWith(status: LatestQuoteStatus.cached, quote: cached));
    }
  }

  Future<void> fetchLatestQuote() async {
    if (_updateService.hasFetchedInitial) {
      final cached = _updateService.latest;
      if (cached != null) {
        emit(state.copyWith(status: LatestQuoteStatus.success, quote: cached));
      }
      return;
    }

    emit(state.copyWith(status: LatestQuoteStatus.loading));
    final quote = await _updateService.refresh();
    if (quote != null) {
      emit(state.copyWith(status: LatestQuoteStatus.success, quote: quote));
    } else {
      emit(state.copyWith(
        status: LatestQuoteStatus.failure,
        errorMessage: 'Gagal memuat quote.',
      ));
    }
  }
}
