import 'dart:async';

import 'package:dear_flutter/data/datasources/remote/home_api_service.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:injectable/injectable.dart';
import 'package:dear_flutter/domain/repositories/quote_cache_repository.dart';

import 'notification_service.dart';

@LazySingleton()
class QuoteUpdateService {
  final HomeApiService _apiService;
  final NotificationService _notificationService;
  final QuoteCacheRepository _cacheRepository;

  Timer? _timer;
  MotivationalQuote? _lastQuote;
  bool _initialFetchDone = false;

  QuoteUpdateService(
      this._apiService, this._notificationService, this._cacheRepository);

  MotivationalQuote? get latest =>
      _lastQuote ?? _cacheRepository.getLastQuote();

  void start({bool immediateFetch = true}) {
    _timer?.cancel();
    if (immediateFetch && !_initialFetchDone) {
      _fetch().whenComplete(() => _initialFetchDone = true);
    }
    _timer = Timer.periodic(const Duration(minutes: 15), (_) => _fetch());
  }

  Future<MotivationalQuote?> refresh() async {
    final quote = await _fetch();
    _initialFetchDone = true;
    return quote;
  }

  bool get hasFetchedInitial => _initialFetchDone;

  Future<MotivationalQuote?> _fetch() async {
    try {
      final quote = await _apiService.getLatestQuote();
      if (_lastQuote == null || quote.id != _lastQuote!.id) {
        _lastQuote = quote;
        await _notificationService.showQuoteNotification(quote);
      }
      await _cacheRepository.saveQuote(quote);
      return _lastQuote;
    } catch (_) {
      // Ignore errors silently, fall back to cached quote
      return _cacheRepository.getLastQuote();
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
