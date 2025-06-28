// lib/data/repositories/auth_repository_impl.dart

import 'package:dear_flutter/data/datasources/local/user_preferences_repository.dart';
import 'package:dear_flutter/data/datasources/remote/auth_api_service.dart';
import 'package:dear_flutter/data/models/requests.dart';
import 'package:dear_flutter/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository) // <-- Anotasi ini sudah benar
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final UserPreferencesRepository _prefs;

  AuthRepositoryImpl(this._apiService, this._prefs);

  // ... (sisa kode login, register, dll. tetap sama)
  @override
  Future<void> login(LoginRequest request) async {
    final response = await _apiService.login(request);
    await _prefs.saveAuthToken(response.accessToken);
  }

  @override
  Future<void> register(RegisterRequest request) async {
    await _apiService.register(request);
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
}