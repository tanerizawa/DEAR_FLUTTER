// lib/presentation/home/cubit/home_cubit.dart

import 'dart:async'; // <-- Import untuk StreamSubscription

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:dear_flutter/presentation/home/cubit/home_state.dart';
import 'package:dear_flutter/domain/usecases/get_journals_usecase.dart'; // <-- IMPORT

@injectable
class HomeCubit extends Cubit<HomeState> {
  final GetJournalsUseCase _getJournalsUseCase;
  StreamSubscription? _journalSubscription; // Untuk 'mendengarkan' perubahan

  HomeCubit(this._getJournalsUseCase) : super(const HomeState());

  void watchJournals() {
    emit(state.copyWith(status: HomeStatus.loading));

    // Berhenti 'mendengarkan' stream lama sebelum memulai yang baru
    _journalSubscription?.cancel();

    _journalSubscription = _getJournalsUseCase().listen(
      (journals) {
        // Jika berhasil, perbarui state dengan data jurnal baru
        emit(state.copyWith(
          status: HomeStatus.success,
          journals: journals,
        ));
      },
      onError: (error) {
        // Jika ada error dari stream, perbarui state kegagalan
        emit(state.copyWith(
          status: HomeStatus.failure,
          errorMessage: 'Gagal memuat jurnal dari database.',
        ));
      },
    );
  }

  // Pastikan kita berhenti 'mendengarkan' saat Cubit tidak lagi digunakan
  @override
  Future<void> close() {
    _journalSubscription?.cancel();
    return super.close();
  }
}