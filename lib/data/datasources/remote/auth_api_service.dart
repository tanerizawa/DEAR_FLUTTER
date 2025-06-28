import 'package:dear_flutter/data/models/requests.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

class AuthResponse {
  final String accessToken;
  AuthResponse({required this.accessToken});
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(accessToken: json['access_token']);
  }
}

@lazySingleton // Pastikan anotasi ini ada
class AuthApiService {
  final Dio _dio;
  AuthApiService(this._dio);

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post('auth/login', data: request.toJson());
    return AuthResponse.fromJson(response.data);
  }

  Future<void> register(RegisterRequest request) async {
    await _dio.post('auth/register', data: request.toJson());
  }
}
