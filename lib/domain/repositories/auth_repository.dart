import 'package:dear_flutter/data/models/requests.dart';

abstract class AuthRepository {
  Future<void> login(LoginRequest request);
  Future<void> register(RegisterRequest request);
  Future<void> logout();
  bool isLoggedIn();
}