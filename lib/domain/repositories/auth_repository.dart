import 'package:dear_flutter/data/models/requests.dart';
import 'package:dear_flutter/domain/entities/user.dart'; 

abstract class AuthRepository {
  Future<void> login(LoginRequest request);
  Future<void> register(RegisterRequest request);
  Future<void> logout();
  bool isLoggedIn();
  Future<User> getProfile(); 
}
