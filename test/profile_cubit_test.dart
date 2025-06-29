import 'package:dear_flutter/data/models/requests.dart';
import 'package:dear_flutter/domain/entities/user.dart';
import 'package:dear_flutter/domain/repositories/auth_repository.dart';
import 'package:dear_flutter/domain/usecases/delete_account_usecase.dart';
import 'package:dear_flutter/domain/usecases/get_user_profile_usecase.dart';
import 'package:dear_flutter/domain/usecases/logout_usecase.dart';
import 'package:dear_flutter/presentation/profile/cubit/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  bool deleteCalled = false;

  @override
  Future<void> deleteAccount() async {
    deleteCalled = true;
  }

  @override
  Future<void> login(LoginRequest request) async {}

  @override
  Future<void> register(RegisterRequest request) async {}

  @override
  Future<void> logout() async {}

  @override
  bool isLoggedIn() => true;

  @override
  Future<User> getProfile() async => const User(id: '1', username: 'u', email: 'e');
}

void main() {
  test('ProfileCubit.deleteAccount delegates to use case', () async {
    final repo = _FakeAuthRepository();
    final cubit = ProfileCubit(
      GetUserProfileUseCase(repo),
      LogoutUseCase(repo),
      DeleteAccountUseCase(repo),
    );

    await cubit.deleteAccount();

    expect(repo.deleteCalled, isTrue);
  });
}
