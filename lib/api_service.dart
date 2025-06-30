import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ===================================================================
// 1. INTERCEPTOR: Otomatis Menambahkan Token ke Setiap Permintaan
// ===================================================================
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Baca token dari penyimpanan aman
    final token = await _storage.read(key: 'jwt_token');

    // Untuk debugging, kita bisa lihat di konsol apakah token ada
    if (token != null) {
      debugPrint('Interceptor: Token ditemukan, menambahkan ke header.');
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      debugPrint('Interceptor: Tidak ada token, permintaan dikirim tanpa header Auth.');
    }

    // Lanjutkan permintaan
    super.onRequest(options, handler);
  }
}

// ===================================================================
// 2. API SERVICE: Pusat dari semua panggilan jaringan
// ===================================================================
class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Ambil URL dasar dari environment yang kita definisikan saat build
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://server-qp6y.onrender.com', // Fallback ke URL produksi
  );

  // Singleton pattern agar kita hanya punya satu instance ApiService
  ApiService._internal()
      : _dio = Dio(BaseOptions(
          baseUrl: _apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        )) {
    // Tambahkan interceptor yang sudah kita buat
    _dio.interceptors.add(AuthInterceptor());
  }
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  // ===================================================================
  // FUNGSI UTAMA
  // ===================================================================

  /// Melakukan login dan menyimpan token jika berhasil.
  /// Mengembalikan true jika sukses, false jika gagal.
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        final token = response.data['access_token'];
        debugPrint('Login sukses, token diterima: $token');
        await _storage.write(key: 'jwt_token', value: token);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error saat login: $e');
      return false;
    }
  }

  /// Mengirim pesan chat. Interceptor akan otomatis menambahkan token.
  Future<void> sendChatMessage(String message) async {
    try {
      // Kita tidak perlu khawatir tentang header di sini, Interceptor yang urus.
      final response = await _dio.post(
        '/api/v1/chat/',
        data: {'message': message},
      );
      debugPrint('Pesan chat berhasil dikirim. Respons AI: ${response.data}');
      // Lakukan sesuatu dengan respons dari AI...
    } on DioException catch (e) {
      // Error 403 akan tertangkap di sini jika Interceptor gagal.
      debugPrint('Error mengirim chat: ${e.response?.data}');
      rethrow; // Lemparkan lagi agar UI bisa menangani
    }
  }

  /// Melakukan logout dengan menghapus token.
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    debugPrint('Logout berhasil, token dihapus.');
  }
}