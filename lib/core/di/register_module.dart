import 'dart:io' show Platform;

import 'package:dear_flutter/core/api/auth_interceptor.dart';
import 'package:dear_flutter/core/api/logging_interceptor.dart';
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
Dio dio(
  AuthInterceptor authInterceptor,
  LoggingInterceptor loggingInterceptor,
) {
  // Ganti IP ini dengan IP lokal komputer Anda
  const localIp = '10.0.2.2'; // <- Sesuaikan dengan IP lokal Anda
  const port = 8000;

  // Buat baseUrl berdasarkan platform
  final baseUrl = kIsWeb
      ? 'http://$localIp:$port/api/v1/'
      : Platform.isAndroid
          ? 'http://$localIp:$port/api/v1/' // Perangkat Android (fisik atau emulator AVD)
          : 'http://$localIp:$port/api/v1/'; // iOS atau desktop
=======
Dio dio(AuthInterceptor authInterceptor) {
  // Mengarahkan ke URL backend di Render.com
  final baseUrl = 'https://server-qp6y.onrender.com/api/v1/';
>>>>>>> Stashed changes
=======
Dio dio(AuthInterceptor authInterceptor) {
  // Mengarahkan ke URL backend di Render.com
  final baseUrl = 'https://server-qp6y.onrender.com/api/v1/';
>>>>>>> Stashed changes

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  dio.interceptors.add(authInterceptor);
  dio.interceptors.add(loggingInterceptor);

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