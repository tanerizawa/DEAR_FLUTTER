import 'package:dear_flutter/data/datasources/local/user_preferences_repository.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@injectable // Daftarkan interceptor ini agar bisa di-inject
class AuthInterceptor extends Interceptor {
  final UserPreferencesRepository _prefs;

  AuthInterceptor(this._prefs);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) {
    // Ambil token dari preferences
    final token = _prefs.getAuthToken();

    // Jika ada token, tambahkan ke header Authorization
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Lanjutkan permintaan
    super.onRequest(options, handler);
  }
}