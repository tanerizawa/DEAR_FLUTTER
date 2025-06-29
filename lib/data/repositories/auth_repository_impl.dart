// lib/data/repositories/auth_repository_impl.dart

import 'package:dear_flutter/data/datasources/local/user_preferences_repository.dart';
import 'package:dear_flutter/data/datasources/remote/auth_api_service.dart';
import 'package:dear_flutter/data/datasources/remote/user_api_service.dart';
import 'package:dear_flutter/data/models/requests.dart';
import 'package:dear_flutter/domain/entities/user.dart';
import 'package:dear_flutter/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;
  final UserApiService _userApiService; // <-- Dependensi untuk profil
  final UserPreferencesRepository _prefs;

  // Konstruktor yang benar, menerima semua service yang dibutuhkan
  AuthRepositoryImpl(
    this._authApiService,
    this._userApiService,
    this._prefs,
  );

  @override
  Future<void> login(LoginRequest request) async {
    final response = await _authApiService.login(request);
    await _prefs.saveAuthToken(response.accessToken);
  }

  @override
  Future<void> register(RegisterRequest request) async {
    await _authApiService.register(request);
    await login(LoginRequest(email: request.email, password: request.password));
  }

  @override
  Future<void> logout() {
    return _prefs.clearAuthToken();
  }

  @override
  bool isLoggedIn() {
    final token = _prefs.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<User> getProfile() {
    // Teruskan panggilan ke UserApiService
    return _userApiService.getProfile();
  }

  @override
  Future<void> deleteAccount() async {
    await _userApiService.deleteAccount();
    await _prefs.clearAuthToken();
  }
}