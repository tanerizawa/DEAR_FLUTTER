import 'package:dear_flutter/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteAccountUseCase {
  final AuthRepository _repository;
  DeleteAccountUseCase(this._repository);

  Future<void> call() => _repository.deleteAccount();
}
