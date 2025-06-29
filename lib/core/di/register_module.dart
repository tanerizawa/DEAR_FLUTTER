import 'dart:io' show Platform;

import 'package:dear_flutter/core/api/auth_interceptor.dart';
import 'package:dear_flutter/data/datasources/local/app_database.dart';
import 'package:dear_flutter/data/datasources/local/chat_message_dao.dart';
import 'package:dear_flutter/data/datasources/local/journal_dao.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModule {
  // --- NETWORK ---
@lazySingleton
Dio dio(AuthInterceptor authInterceptor) {
  const port = 8000;

  // Use Android loopback when running on an emulator, otherwise default to
  // localhost so the backend can be reached from web, iOS or desktop.
  final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  final baseUrl = 'http://$host:$port/api/v1/';

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  dio.interceptors.add(authInterceptor);
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
}


  // --- DATABASE ---
  @singleton
  AppDatabase get database => AppDatabase();

  @lazySingleton
  JournalDao journalDao(AppDatabase db) => db.journalDao;

  @lazySingleton
  ChatMessageDao chatMessageDao(AppDatabase db) => db.chatMessageDao;

  // --- PREFERENCES ---
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
