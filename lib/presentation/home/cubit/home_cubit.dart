import 'dart:async';

import 'package:dear_flutter/domain/usecases/get_journals_usecase.dart';
import 'package:dear_flutter/domain/usecases/sync_journals_usecase.dart';
import 'package:dear_flutter/presentation/home/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final GetJournalsUseCase _getJournalsUseCase;
  final SyncJournalsUseCase _syncJournalsUseCase;
  StreamSubscription? _journalSubscription;

  HomeCubit(this._getJournalsUseCase, this._syncJournalsUseCase)
      : super(const HomeState()) {
    // Jalankan pemantauan dan sinkronisasi jurnal saat cubit diinisialisasi
    watchJournals();
    syncJournals(); // <-- Sudah tidak dikomentari
  }

  Future<void> syncJournals() async {
    try {
      await _syncJournalsUseCase();
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }

  void watchJournals() {
    emit(state.copyWith(status: HomeStatus.loading));

    _journalSubscription?.cancel();

    _journalSubscription = _getJournalsUseCase().listen(
      (journals) {
        emit(state.copyWith(
          status: HomeStatus.success,
          journals: journals,
        ));
      },
      onError: (error) {
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
