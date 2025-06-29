import 'package:dear_flutter/domain/usecases/get_user_profile_usecase.dart';
import 'package:dear_flutter/domain/usecases/logout_usecase.dart';
import 'package:dear_flutter/domain/usecases/delete_account_usecase.dart';
import 'package:dear_flutter/presentation/profile/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final LogoutUseCase _logoutUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  ProfileCubit(
      this._getUserProfileUseCase,
      this._logoutUseCase,
      this._deleteAccountUseCase,
      ) : super(const ProfileState()) {
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await _getUserProfileUseCase();
      emit(state.copyWith(status: ProfileStatus.success, user: user));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, errorMessage: 'Gagal memuat profil'));
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
  }

  Future<void> deleteAccount() async {
    await _deleteAccountUseCase();
  }
}