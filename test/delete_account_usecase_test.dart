import 'package:dear_flutter/domain/repositories/auth_repository.dart';
import 'package:dear_flutter/domain/usecases/delete_account_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dear_flutter/data/models/requests.dart';
import 'package:dear_flutter/domain/entities/user.dart';

class _FakeAuthRepository implements AuthRepository {
  bool called = false;

  @override
  Future<void> deleteAccount() async {
    called = true;
  }

  @override
  Future<void> login(LoginRequest request) async {}

  @override
  Future<void> register(RegisterRequest request) async {}

  @override
  Future<void> logout() async {}

  @override
  bool isLoggedIn() => false;

  @override
  Future<User> getProfile() async => const User(id: 1, username: 'u', email: 'e');
}

void main() {
  test('DeleteAccountUseCase calls repository', () async {
    final repo = _FakeAuthRepository();
    final usecase = DeleteAccountUseCase(repo);

    await usecase();

    expect(repo.called, isTrue);
  });
}
