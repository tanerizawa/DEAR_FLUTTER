// lib/presentation/home/cubit/home_feed_cubit.dart

import 'package:dear_flutter/domain/entities/home_feed.dart'; // -> IMPORT TAMBAHAN
import 'package:dear_flutter/domain/entities/journal.dart';
import 'package:dear_flutter/domain/repositories/home_repository.dart';
import 'package:dear_flutter/domain/repositories/journal_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

import 'home_feed_state.dart';

@injectable
class HomeFeedCubit extends Cubit<HomeFeedState> {
  final HomeRepository _homeRepository;
  final JournalRepository _journalRepository;

  HomeFeedCubit(this._homeRepository, this._journalRepository) : super(const HomeFeedState());

  Future<void> fetchHomeFeed() async {
    if (state.status == HomeFeedStatus.loading) return;
    emit(state.copyWith(status: HomeFeedStatus.loading));
    debugPrint("[HomeFeedCubit] Mulai mengambil data home feed dan jurnal...");

    try {
      final results = await Future.wait([
        _homeRepository.getHomeFeed(),
        _journalRepository.getJournals().first,
      ]);

      final feed = results[0] as HomeFeed; // Ini sekarang akan valid
      final journals = results[1] as List<Journal>;
      final lastMood = journals.isNotEmpty ? journals.first.mood : null;

      debugPrint("[HomeFeedCubit] DATA BERHASIL DITERIMA. Mood terakhir: $lastMood");
      
      emit(state.copyWith(
        status: HomeFeedStatus.success,
        feed: feed,
        lastMood: lastMood,
      ));
    } catch (e, stackTrace) {
      debugPrint("[HomeFeedCubit] GAGAL MENGAMBIL DATA: $e");
      debugPrint(stackTrace.toString());
      emit(state.copyWith(
        status: HomeFeedStatus.failure,
        errorMessage: 'Gagal memuat data. Silakan coba lagi.',
      ));
    }
  }

  Future<void> refreshHomeFeed() async {
     await fetchHomeFeed();
  }
}