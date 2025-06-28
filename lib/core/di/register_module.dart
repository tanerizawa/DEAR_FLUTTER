// lib/core/di/register_module.dart

import 'package:dear_flutter/core/api/auth_interceptor.dart';
import 'package:dear_flutter/core/api/dio_client.dart';
import 'package:dear_flutter/data/datasources/local/app_database.dart';
import 'package:dear_flutter/data/datasources/local/journal_dao.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

// File ini akan menjadi SATU-SATUNYA sumber untuk anotasi @module

@module
abstract class RegisterModule {
  // --- NETWORK ---
  @singleton
  Dio get dio => createDioClient(UserPreferencesRepository());

  // --- DATABASE ---
  @singleton
  AppDatabase get database => AppDatabase();

  @lazySingleton
  JournalDao provideJournalDao(AppDatabase db) => db.journalDao;
}