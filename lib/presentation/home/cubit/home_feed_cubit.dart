import 'package:dear_flutter/domain/usecases/get_home_feed_usecase.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeFeedCubit extends Cubit<HomeFeedState> {
  final GetHomeFeedUseCase _getHomeFeedUseCase;

  HomeFeedCubit(this._getHomeFeedUseCase) : super(const HomeFeedState()) {
    fetchHomeFeed();
  }

  Future<void> fetchHomeFeed() async {
    emit(state.copyWith(status: HomeFeedStatus.loading));
    try {
      final items = await _getHomeFeedUseCase();
      emit(state.copyWith(status: HomeFeedStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: HomeFeedStatus.failure,
        errorMessage: 'Gagal memuat feed.',
      ));
    }
  }
}
