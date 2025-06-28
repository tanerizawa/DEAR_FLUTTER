import 'package:dear_flutter/data/models/requests.dart';
import 'package:dear_flutter/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<void> call({required String email, required String password}) {
    final request = LoginRequest(email: email, password: password);
    return _repository.login(request);
  }
}