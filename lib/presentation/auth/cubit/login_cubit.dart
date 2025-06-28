import 'package:dear_flutter/domain/usecases/login_usecase.dart';
import 'package:dear_flutter/presentation/auth/cubit/login_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginCubit(this._loginUseCase) : super(const LoginState());

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      await _loginUseCase(email: email, password: password);
      emit(state.copyWith(status: LoginStatus.success));
    } on DioException catch (e) {
      // Tangani error spesifik dari Dio (misal: 401 Unauthorized)
      final errorMessage = e.response?.data['detail'] ?? 'Login gagal. Periksa kembali email dan password Anda.';
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: errorMessage,
      ));
    } catch (e) {
      // Tangani error umum lainnya
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Terjadi kesalahan. Coba lagi.',
      ));
    }
  }
}
