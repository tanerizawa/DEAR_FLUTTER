import 'package:dear_flutter/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAuthStatusUseCase {
  final AuthRepository _repository;

  GetAuthStatusUseCase(this._repository);

  // Panggil fungsi isLoggedIn dari repository
  bool call() {
    return _repository.isLoggedIn();
  }
}