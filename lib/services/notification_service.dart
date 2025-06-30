import 'dart:convert';

import 'package:dear_flutter/core/navigation/app_router.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload == null) return;
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final quote = MotivationalQuote.fromJson(data);
        router.push('/quote', extra: quote);
      },
    );
  }

  Future<void> showQuoteNotification(MotivationalQuote quote) async {
    const androidDetails = AndroidNotificationDetails(
      'quote_channel',
      'Quotes',
      channelDescription: 'Motivational quote notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      quote.id,
      'Motivation',
      '"${quote.text}" - ${quote.author}',
      notificationDetails,
      payload: jsonEncode(quote.toJson()),
    );
  }
}
