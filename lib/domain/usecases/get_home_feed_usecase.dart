import 'package:injectable/injectable.dart';
import 'package:dear_flutter/domain/entities/home_feed_item.dart';
import 'package:dear_flutter/domain/repositories/home_repository.dart';

@injectable
class GetHomeFeedUseCase {
  final HomeRepository _repository;
  GetHomeFeedUseCase(this._repository);

  Future<List<HomeFeedItem>> call() => _repository.getHomeFeed();
}
