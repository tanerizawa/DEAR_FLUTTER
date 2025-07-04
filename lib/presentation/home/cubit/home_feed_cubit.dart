// lib/presentation/home/cubit/home_feed_cubit.dart

import 'package:dear_flutter/domain/repositories/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart'; // Import untuk debugPrint

import 'home_feed_state.dart';

@injectable
class HomeFeedCubit extends Cubit<HomeFeedState> {
  final HomeRepository _repository;

  HomeFeedCubit(this._repository) : super(const HomeFeedState());

  Future<void> fetchHomeFeed() async {
    // Memberi tahu UI bahwa proses loading dimulai
    emit(state.copyWith(status: HomeFeedStatus.loading));
    debugPrint("[HomeFeedCubit] Mulai mengambil data home feed...");

    try {
      // Memanggil repository untuk mengambil data dari server
      final feed = await _repository.getHomeFeed();
      
      // MENCETAK DATA YANG DITERIMA UNTUK DEBUGGING
      // Anda bisa melihat ini di Debug Console
      debugPrint("[HomeFeedCubit] DATA BERHASIL DITERIMA: ${feed.toString()}");
      
      // Memberi tahu UI bahwa data berhasil didapat
      emit(state.copyWith(status: HomeFeedStatus.success, feed: feed));
    } catch (e, stackTrace) {
      // MENCETAK ERROR JIKA TERJADI
      debugPrint("[HomeFeedCubit] GAGAL MENGAMBIL DATA: $e");
      debugPrint(stackTrace.toString());

      // Memberi tahu UI bahwa terjadi kegagalan
      emit(state.copyWith(
        status: HomeFeedStatus.failure,
        errorMessage: 'Gagal memuat data. Silakan coba lagi.',
      ));
    }
  }
}