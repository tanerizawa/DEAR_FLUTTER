import 'package:dear_flutter/domain/repositories/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'home_feed_state.dart';

@injectable
class HomeFeedCubit extends Cubit<HomeFeedState> {
  final HomeRepository _repository;

  HomeFeedCubit(this._repository) : super(const HomeFeedState());

  Future<void> fetchHomeFeed() async {
    emit(state.copyWith(status: HomeFeedStatus.loading));
    try {
      final feed = await _repository.getHomeFeed();
      emit(state.copyWith(status: HomeFeedStatus.success, feed: feed));
    } catch (e) {
      emit(state.copyWith(
        status: HomeFeedStatus.failure,
        errorMessage: 'Gagal memuat home feed.',
      ));
    }
  }
}
