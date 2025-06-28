import 'package:dear_flutter/data/models/requests.dart';
import 'package:dear_flutter/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<void> call({
    required String username,
    required String email,
    required String password,
  }) {
    final request = RegisterRequest(
      username: username,
      email: email,
      password: password,
    );
    return _repository.register(request);
  }
}
