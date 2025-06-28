// lib/core/api/auth_interceptor.dart

import 'package:dio/dio.dart';

// TODO: Nanti kita akan inject UserPreferencesRepository di sini
// Untuk sekarang, kita buat class kosong sebagai placeholder
class UserPreferencesRepository {
  Future<String?> get authToken => Future.value(null); // Placeholder
}

class AuthInterceptor extends Interceptor {
  final UserPreferencesRepository _prefs;

  AuthInterceptor(this._prefs);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Ambil token dari preferences
    final token = await _prefs.authToken;

    // Jika ada token, tambahkan ke header Authorization
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Lanjutkan request
    super.onRequest(options, handler);
  }
}