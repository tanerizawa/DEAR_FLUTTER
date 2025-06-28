// lib/core/di/register_module.dart

import 'package:dear_flutter/data/datasources/local/app_database.dart';
import 'package:dear_flutter/data/datasources/local/journal_dao.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RegisterModule {
  // --- NETWORK ---
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:8000/api/v1/', // Pastikan URL ini benar
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    return dio;
  }

  // --- DATABASE ---
  @singleton
  AppDatabase get database => AppDatabase();

  // INI BAGIAN PENTING:
  // Secara eksplisit menyediakan JournalDao dari AppDatabase
  @lazySingleton
  JournalDao journalDao(AppDatabase db) => db.journalDao;
}