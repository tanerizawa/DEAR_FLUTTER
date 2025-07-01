import 'package:dear_flutter/domain/entities/user.dart'; // Kita akan gunakan User entity yang sudah ada
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UserApiService {
  final Dio _dio;
  UserApiService(this._dio);

  // GET /users/me
  Future<User> getProfile() async {
    final response = await _dio.get('users/me');
    return User.fromJson(response.data);
  }

  Future<void> deleteAccount() async {
    await _dio.delete('users/me');
  }
}
