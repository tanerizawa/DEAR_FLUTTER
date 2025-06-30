import 'package:dear_flutter/domain/usecases/get_home_feed_usecase.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeFeedCubit extends Cubit<HomeFeedState> {
  final GetHomeFeedUseCase _getHomeFeedUseCase;

  HomeFeedCubit(this._getHomeFeedUseCase) : super(const HomeFeedState()) {
    fetchHomeFeed();
  }

  Future<void> fetchHomeFeed() async {
    debugPrint('Fetching home feed');
    emit(state.copyWith(status: HomeFeedStatus.loading));
    try {
      final items = await _getHomeFeedUseCase();
      debugPrint('Home feed loaded with ${items.length} items');
      emit(state.copyWith(status: HomeFeedStatus.success, items: items));
    } catch (e) {
      debugPrint('Home feed error: $e');
      emit(state.copyWith(
        status: HomeFeedStatus.failure,
        errorMessage: 'Gagal memuat feed.',
      ));
    }
  }
}
