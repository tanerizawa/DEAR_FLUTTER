// lib/presentation/home/cubit/home_cubit.dart

import 'dart:async';

import 'package:dear_flutter/domain/usecases/get_journals_usecase.dart';
import 'package:dear_flutter/domain/usecases/sync_journals_usecase.dart'; // <-- IMPORT
import 'package:dear_flutter/presentation/home/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final GetJournalsUseCase _getJournalsUseCase;
  final SyncJournalsUseCase _syncJournalsUseCase;
  StreamSubscription? _journalSubscription;

  HomeCubit(this._getJournalsUseCase, this._syncJournalsUseCase)
      : super(const HomeState()) {
    // Panggil kedua fungsi saat Cubit dibuat
    watchJournals();
    // syncJournals(); // <--- BERI KOMENTAR PADA BARIS INI
  }

  Future<void> syncJournals() async {
    try {
      await _syncJournalsUseCase();
    } catch (e) {
      // Di aplikasi nyata, kita bisa menampilkan Snackbar atau pesan error
      print("Sync failed: $e");
    }
  }

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

  @override
  Future<void> close() {
    _journalSubscription?.cancel();
    return super.close();
  }
}