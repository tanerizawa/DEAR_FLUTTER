import 'package:dear_flutter/domain/entities/user.dart';
import 'package:dear_flutter/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetUserProfileUseCase {
  final AuthRepository _repository;
  GetUserProfileUseCase(this._repository);

  Future<User> call() => _repository.getProfile();
}
