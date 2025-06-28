import 'package:dear_flutter/domain/usecases/register_usecase.dart';
import 'package:dear_flutter/presentation/auth/cubit/register_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterCubit(this._registerUseCase) : super(const RegisterState());

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _registerUseCase(
        username: username,
        email: email,
        password: password,
      );
      emit(state.copyWith(status: AuthStatus.success));
    } on DioException catch (e) {
      final errorMessage = e.response?.data['detail'] ?? 'Registrasi gagal. Coba lagi.';
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: errorMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Terjadi kesalahan tidak dikenal.',
      ));
    }
  }
}