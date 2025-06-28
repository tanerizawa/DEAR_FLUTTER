// lib/core/api/dio_client.dart

import 'package:dio/dio.dart';
import 'package:dear_flutter/core/api/auth_interceptor.dart';

Dio createDioClient(UserPreferencesRepository prefs) {
  final dio = Dio(
    BaseOptions(
      // Ganti dengan Base URL dari API Anda (dari BuildConfig di Android)
      baseUrl: 'http://10.0.2.2:8000/api/v1/', 
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  // Tambahkan interceptor untuk logging (mirip HttpLoggingInterceptor)
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  // Tambahkan interceptor autentikasi kita
  dio.interceptors.add(AuthInterceptor(prefs));

  return dio;
}