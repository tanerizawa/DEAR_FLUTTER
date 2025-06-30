import 'dart:async';

import 'package:dear_flutter/data/datasources/remote/home_api_service.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:injectable/injectable.dart';

import 'notification_service.dart';

@LazySingleton()
class QuoteUpdateService {
  final HomeApiService _apiService;
  final NotificationService _notificationService;

  Timer? _timer;
  MotivationalQuote? _lastQuote;

  QuoteUpdateService(this._apiService, this._notificationService);

  void start() {
    _timer?.cancel();
    _fetch();
    _timer = Timer.periodic(const Duration(minutes: 15), (_) => _fetch());
  }

  Future<void> _fetch() async {
    try {
      final quote = await _apiService.getLatestQuote();
      if (_lastQuote == null || quote.id != _lastQuote!.id) {
        _lastQuote = quote;
        await _notificationService.showQuoteNotification(quote);
      }
    } catch (_) {
      // Ignore errors silently
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
